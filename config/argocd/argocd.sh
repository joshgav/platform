#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

namespace=argocd
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace ${namespace}

echo "INFO: install argocd"
kustomize build ${this_dir} | kubectl apply -n ${namespace} -f -
