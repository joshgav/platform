#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

apply_kustomize_dir ${this_dir}/operator
await_resource_ready quayregistries

# ensure_namespace quay
# ensure_bucket registry-quay-datastore quay true
# S3_ENDPOINT_URL=$(echo "${S3_ENDPOINT_URL}" | sed 's/^https*:\/\///' | sed 's/:.*$//')
# echo "INFO: using S3_ENDPOINT_URL: ${S3_ENDPOINT_URL}"

apply_kustomize_dir ${this_dir}/registry
