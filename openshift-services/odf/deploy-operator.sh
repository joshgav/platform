#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

apply_kustomize_dir ${this_dir}/operator
await_resource_ready storageclusters
await_resource_ready objectbucketclaims

oc patch console.operator.openshift.io cluster \
    --type=json -p='[{"op": "add", "path": "/spec/plugins/-", "value": "odf-console"}]'
