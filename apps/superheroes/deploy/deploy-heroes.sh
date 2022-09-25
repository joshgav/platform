#! /usr/bin/env bash

service=rest-heroes

echo "INFO: deploying service ${service}"

render_yaml ${app_dir}/${service} && kustomize build ${app_dir}/${service} | kubectl apply -f -

pushd "${repo_dir}/${service}"

# install service-binding extension
quarkus extension add quarkus-kubernetes-service-binding
# remove upstream kubernetes manifests so they are regenerated
rm -rf ${repo_dir}/${service}/src/main/kubernetes
# quarkus deploy
./mvnw clean package ${extra_args} \
    -Dquarkus.profile=${profile} \
    -Dquarkus.container-image.group=${container_image_group_name} \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests \
    -Dquarkus.kubernetes.namespace=${app_namespace} \
    -Dquarkus.kubernetes-service-binding.services.heroes-db.api-version=postgres-operator.crunchydata.com/v1beta1 \
    -Dquarkus.kubernetes-service-binding.services.heroes-db.kind=PostgresCluster \
    -Dquarkus.kubernetes-service-binding.services.heroes-db.name=heroes-db \
    -Dquarkus.datasource.db-kind=postgresql \
    -Dquarkus.datasource.jdbc.driver=org.postgresql.Driver \
    -Dquarkus.datasource.reactive.postgresql.ssl-mode=prefer

popd
