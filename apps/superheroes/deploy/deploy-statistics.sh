#! /usr/bin/env bash

service=event-statistics

echo "INFO: deploying service ${service}"

render_yaml ${app_dir}/${service} && kustomize build ${app_dir}/${service} | kubectl apply -f -

pushd "${repo_dir}/${service}"
# remove upstream kubernetes manifests so they are regenerated
rm -rf ${repo_dir}/${service}/src/main/kubernetes

echo "INFO: deploying app components"
./mvnw clean package \
    -Dquarkus.profile=kubernetes-17 \
    -Dquarkus.kubernetes.deployment-target=kubernetes \
    -Dquarkus.container-image.group=${container_image_group_name} \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests \
    -Dquarkus.kubernetes.namespace=${app_namespace}

popd
