#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/ensure_bucket.sh

namespace=tempo-observability
ensure_namespace ${namespace}

## this function exports ${S3_ENDPOINT_URL}, ${S3_ACCESS_KEY_ID}, ${S3_SECRET_ACCESS_KEY}, ${S3_BUCKET_NAME}
ensure_bucket tempo-data ${namespace}

apply_kustomize_dir ${this_dir}/tempostack
