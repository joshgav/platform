#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

container_image_group_name=${1:-"joshgav"}

repo_dir=${this_dir}/superheroes

## clone kubespray for ease of use of contrib files
if [[ ! -e "${repo_dir}/pom.xml" ]]; then
    git clone https://github.com/quarkusio/quarkus-super-heroes.git ${repo_dir}
fi

pushd "${repo_dir}/rest-villains"
trap "popd" EXIT

cp ${this_dir}/rest-villains-db.yml ${repo_dir}/rest-villains/src/main/kubernetes/knative.yml
quarkus extension add quarkus-kubernetes-service-binding

./mvnw clean package \
    -Dquarkus.profile=knative-17 \
    -Dquarkus.container-image.group=${container_image_group_name} \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests \
    -Dquarkus.knative.namespace=superheroes \
    -Dquarkus.kubernetes-service-binding.services.villains-db.api-version=postgres-operator.crunchydata.com/v1beta1 \
    -Dquarkus.kubernetes-service-binding.services.villains-db.kind=PostgresCluster \
    -Dquarkus.kubernetes-service-binding.services.villains-db.name=villains-db
