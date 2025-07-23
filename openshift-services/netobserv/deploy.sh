#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/ensure_bucket.sh

namespace=netobserv
ensure_namespace ${namespace} true

echo "INFO: installing loki-operator"
apply_kustomize_dir ${this_dir}/loki-operator
await_resource_ready "lokistacks"

bucket_name=loki-data
ensure_bucket ${bucket_name} ${namespace}
# S3_ENDPOINT_URL=$(echo "${S3_ENDPOINT_URL}" | sed 's/^https*:\/\///' | sed 's/:.*$//')
echo "INFO: using S3_ENDPOINT_URL: ${S3_ENDPOINT_URL}"

apply_kustomize_dir ${this_dir}/loki-operand
# oc wait --for=condition=Ready lokistacks loki -n ${namespace}

echo "INFO: installing netobserv-operator"
apply_kustomize_dir ${this_dir}/netobserv-operator
await_resource_ready "flowcollector"

apply_kustomize_dir ${this_dir}/netobserv-operand
