#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

apply_kustomize_dir ${this_dir}/operator
await_resource_ready storagesystems
await_resource_ready storageclusters
await_resource_ready objectbucketclaims

apply_kustomize_dir ${this_dir}/storage
