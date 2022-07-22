#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
repo_dir=${this_dir}/superheroes

container_image_group_name=${1:-"joshgav"}

namespace=superheroes
kubectl config set-context --current --namespace ${namespace}

if [[ ! -e "${repo_dir}/pom.xml" ]]; then
    git clone https://github.com/quarkusio/quarkus-super-heroes.git ${repo_dir}
fi

for service in "villains" "heroes"; do
    echo "INFO: deploying service ${service}"
    kustomize build ${this_dir}/rest-${service} | kubectl apply -f -

    pushd "${repo_dir}/rest-${service}"
    quarkus extension add quarkus-kubernetes-service-binding
    rm -rf ${repo_dir}/rest-${service}/src/main/kubernetes

    ./mvnw clean package \
        -Dquarkus.profile=knative-17 \
        -Dquarkus.container-image.group=${container_image_group_name} \
        -Dquarkus.kubernetes.deploy=true \
        -DskipTests \
        -Dquarkus.knative.namespace=superheroes \
        -Dquarkus.kubernetes-service-binding.services.villains-db.api-version=postgres-operator.crunchydata.com/v1beta1 \
        -Dquarkus.kubernetes-service-binding.services.villains-db.kind=PostgresCluster \
        -Dquarkus.kubernetes-service-binding.services.villains-db.name=${service}-db

    popd
done




