#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=app
kubectl create namespace ${namespace} 2> /dev/null || true

if is_openshift; then
    dir_name=base-openshift
else
    dir_name=base-k8s
fi

kustomize build ${this_dir}/${dir_name} | kubectl apply -n ${namespace} -f -
