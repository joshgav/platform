#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

ensure_namespace noobaa true
noobaa install
await_resource_ready noobaa

kustomize build ${this_dir}/bucketclass | oc apply -f -
