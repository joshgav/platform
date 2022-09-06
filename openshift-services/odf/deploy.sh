#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/yaml.sh
source ${root_dir}/lib/olm.sh

apply_kustomize_dir ${this_dir}/operator
await_resource_ready storagesystems

apply_kustomize_dir ${this_dir}/storage
await_resource_ready storageclusters
await_resource_ready objectbucketclaims
