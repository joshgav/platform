#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

## Subscription via OLM
echo "INFO: install operator subscription"
kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready "tektonconfig"

kustomize build ${this_dir}/pipelines | oc apply -f -
