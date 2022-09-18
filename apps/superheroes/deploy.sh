#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

container_image_group_name=${1:-"joshgav"}

kubectl api-resources | grep -q PostgresCluster
if [[ ${?} != 0 ]]; then
    echo "ERROR: app depends on postgres-operator.crunchydata.com/v1beta1 API"
    exit 2
fi

namespace=quarkus-superheroes
ensure_namespace ${namespace} true

repo_dir=${this_dir}/superheroes
if [[ ! -e "${repo_dir}/pom.xml" ]]; then
    git clone https://github.com/quarkusio/quarkus-super-heroes.git ${repo_dir}
fi

for service in "villains" "heroes"; do
    echo "INFO: deploying service ${service}"
    echo "INFO: deploying dependencies"
    kustomize build ${this_dir}/rest-${service} | kubectl apply -f -

    pushd "${repo_dir}/rest-${service}"
    quarkus extension add quarkus-kubernetes-service-binding
    rm -rf ${repo_dir}/rest-${service}/src/main/kubernetes

    echo "INFO: deploying app components"
    ./mvnw clean package \
        -Dquarkus.profile=knative-17 \
        -Dquarkus.container-image.group=${container_image_group_name} \
        -Dquarkus.kubernetes.deploy=true \
        -DskipTests \
        -Dquarkus.knative.namespace=${namespace} \
        -Dquarkus.kubernetes-service-binding.services.${service}-db.api-version=postgres-operator.crunchydata.com/v1beta1 \
        -Dquarkus.kubernetes-service-binding.services.${service}-db.kind=PostgresCluster \
        -Dquarkus.kubernetes-service-binding.services.${service}-db.name=${service}-db \
        -Dquarkus.hibernate-orm.sql-load-script=no-file \
        -Dquarkus.datasource.db-kind=postgresql \
        -Dquarkus.datasource.jdbc.driver=org.postgresql.Driver \
        -Dquarkus.datasource.reactive.postgresql.ssl-mode=prefer
    popd
done

kustomize build ${this_dir}/rest-fights | kubectl apply -f -
oc adm policy add-scc-to-user anyuid -n ${namespace} -z mongodb-database
oc adm policy add-role-to-user edit -z mongodb-database
