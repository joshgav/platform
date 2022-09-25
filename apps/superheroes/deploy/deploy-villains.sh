#! /usr/bin/env bash

service=rest-villains

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
    -Dquarkus.kubernetes-service-binding.services.villains-db.api-version=postgres-operator.crunchydata.com/v1beta1 \
    -Dquarkus.kubernetes-service-binding.services.villains-db.kind=PostgresCluster \
    -Dquarkus.kubernetes-service-binding.services.villains-db.name=villains-db \
    -Dquarkus.hibernate-orm.sql-load-script=no-file \
    -Dquarkus.datasource.db-kind=postgresql \
    -Dquarkus.datasource.jdbc.driver=org.postgresql.Driver

popd
