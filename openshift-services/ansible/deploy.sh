#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready automationcontrollers

ansible_controller_namespace=ansible-automation-controller
ansible_hub_bucket_name=ansible-automation-hub

ensure_namespace ${ansible_controller_namespace}
ensure_bucket ${ansible_hub_bucket_name} ${ansible_controller_namespace}

export S3_REGION=${S3_REGION:-''}

apply_kustomize_dir ${this_dir}/operand
