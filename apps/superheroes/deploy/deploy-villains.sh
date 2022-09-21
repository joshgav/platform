#! /usr/bin/env bash

service=rest-villains

echo "INFO: deploying service ${service}"
echo "INFO: deploying service dependencies"
kustomize build ${app_dir}/${service} | kubectl apply -f -

pushd "${repo_dir}/${service}"
quarkus extension add quarkus-kubernetes-service-binding
rm -rf ${repo_dir}/${service}/src/main/kubernetes

echo "INFO: deploying app components"
./mvnw clean package \
    -Dquarkus.profile=kubernetes-17 \
    -Dquarkus.kubernetes.deployment-target=kubernetes \
    -Dquarkus.container-image.group=${container_image_group_name} \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests \
    -Dquarkus.kubernetes.namespace=${namespace} \
    -Dquarkus.kubernetes-service-binding.services.villains-db.api-version=postgres-operator.crunchydata.com/v1beta1 \
    -Dquarkus.kubernetes-service-binding.services.villains-db.kind=PostgresCluster \
    -Dquarkus.kubernetes-service-binding.services.villains-db.name=villains-db \
    -Dquarkus.hibernate-orm.sql-load-script=no-file \
    -Dquarkus.datasource.db-kind=postgresql \
    -Dquarkus.datasource.jdbc.driver=org.postgresql.Driver \
    -Dquarkus.datasource.reactive.postgresql.ssl-mode=prefer

popd
