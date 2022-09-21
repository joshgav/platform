#! /usr/bin/env bash

service=rest-fights

echo "INFO: deploying service ${service}"
echo "INFO: deploying dependencies"
kustomize build ${app_dir}/${service} | kubectl apply -f -

# policies required by mongodb serviceaccount
oc adm policy add-scc-to-user anyuid -n ${namespace} -z mongodb-database
oc adm policy add-role-to-user edit -z mongodb-database

fights_db_username=fights-user
fights_db_password=$(oc get secrets "${fights_db_username}-mongodb-password" -ojson | jq -r '.data.password | @base64d')

pushd "${repo_dir}/${service}"
rm -rf ${repo_dir}/${service}/src/main/kubernetes

echo "INFO: deploying app components"
./mvnw clean package \
    -Dquarkus.profile=kubernetes-17 \
    -Dquarkus.kubernetes.deployment-target=kubernetes \
    -Dquarkus.container-image.group=${container_image_group_name} \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests \
    -Dquarkus.kubernetes.namespace=${namespace} \
    -Dquarkus.liquibase-mongodb.migrate-at-start=false \
    -Dquarkus.mongodb.credentials.username=${fights_db_username} \
    -Dquarkus.mongodb.credentials.password=${fights_db_password} \
    -Dquarkus.mongodb.hosts=fights-db:27017

popd
