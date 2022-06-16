#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep tekton &> /dev/null
    ready=$?
done

kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/docker-build/0.1/docker-build.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildah/0.3/buildah.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/gradle/0.1/gradle.yaml
# kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/s2i/s2i.yaml
# kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/buildpacks/0.4/buildpacks.yaml

source ${this_dir}/quay/.env
cat ${this_dir}/quay/pull-secret.yaml.tpl | envsubst > ${this_dir}/quay/pull-secret.yaml
trap "rm -f ${this_dir}/quay/pull-secret.yaml" EXIT

kustomize build ${this_dir}/base | kubectl apply -f -
kustomize build ${this_dir}/quay | kubectl apply -f -
