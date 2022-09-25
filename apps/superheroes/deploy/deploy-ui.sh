#! /usr/bin/env bash

service=ui-super-heroes

echo "INFO: deploying service ${service}"
docker build -t quay.io/${container_image_group_name}/ui-super-heroes:latest "${repo_dir}/${service}"
docker push quay.io/${container_image_group_name}/ui-super-heroes:latest

render_yaml ${app_dir}/${service} && kustomize build ${app_dir}/${service} | kubectl apply -f -
