#! /usr/bin/env bash

service=rest-fights

echo "INFO: deploying service ${service}"

render_yaml ${app_dir}/${service} && kustomize build ${app_dir}/${service} | kubectl apply -f -

pushd "${repo_dir}/${service}"

# policies required by mongodb serviceaccount
oc adm policy add-scc-to-user anyuid -n ${app_namespace} -z mongodb-database
oc adm policy add-role-to-user edit -z mongodb-database

# TODO: use service-binding operator
fights_db_username=fights-user
fights_db_password=$(oc get secrets "${fights_db_username}-mongodb-password" -ojson | jq -r '.data.password | @base64d')
fights_db_host='fights-db:27017'

pushd "${repo_dir}/${service}"

# TODO: use service-binding operator
# # install service-binding extension
# quarkus extension add quarkus-kubernetes-service-binding

# remove upstream kubernetes manifests so they are regenerated
rm -rf ${repo_dir}/${service}/src/main/kubernetes
# quarkus deploy
./mvnw clean package ${extra_args} \
    -Dquarkus.profile=${profile} \
    -Dquarkus.container-image.group=${container_image_group_name} \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests \
    -Dquarkus.kubernetes.namespace=${app_namespace} \
    -Dquarkus.mongodb.credentials.username=${fights_db_username} \
    -Dquarkus.mongodb.credentials.password=${fights_db_password} \
    -Dquarkus.mongodb.hosts=${fights_db_host}

    # TODO: use service-binding operator
    # -Dquarkus.kubernetes-service-binding.services.fights-db.api-version=mongodbcommunity.mongodb.com/v1 \
    # -Dquarkus.kubernetes-service-binding.services.fights-db.kind=MongoDBCommunity \
    # -Dquarkus.kubernetes-service-binding.services.fights-db.name=fights-db

popd
