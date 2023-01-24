#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

create_subscription devspaces openshift-operators
await_resource_ready 'checluster'

echo "INFO: render and apply manifests"
kustomize build ${this_dir}/base | oc apply -f -
