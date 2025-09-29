#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/ensure_bucket.sh

namespace=openshift-logging
ensure_namespace ${namespace} true

echo "INFO: installing required operators"
apply_kustomize_dir ${this_dir}/operators
await_resource_ready "clusterlogforwarders"
await_resource_ready "lokistacks"

export S3_BUCKET_NAME=${S3_BUCKET_NAME:-loki-data}
ensure_bucket ${S3_BUCKET_NAME} ${namespace}
apply_kustomize_dir ${this_dir}/loki
oc wait --for=condition=Ready lokistacks logging-loki --timeout -1s

apply_kustomize_dir ${this_dir}/logging
