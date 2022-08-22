#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/olm.sh

namespace=app
kubectl create namespace ${namespace} 2> /dev/null || true

source ${this_dir}/.env
if is_openshift; then
    dir_name=base-openshift
else
    dir_name=base-k8s
fi

# source ${this_dir}/.env
# cat ${this_dir}/keycloak/kustomization.yaml.tpl | envsubst > ${this_dir}/${dir_name}/kustomization.yaml
# trap "rm -f ${this_dir}/${dir_name}/kustomization.yaml" EXIT
## TODO: edit base pointer based on `is_openshift`
##       for this, also need to adjust the branch pointer to a git branch with keycloak configured
# kustomize build ${this_dir}/keycloak | kubectl apply -n ${namespace} -f -
## TODO: make this work, then trigger a refresh of the deployment
# kustomize build ${this_dir}/pipeline | kubectl apply -n ${namespace} -f -

kustomize build ${this_dir}/${dir_name} | kubectl apply -n ${namespace} -f -
