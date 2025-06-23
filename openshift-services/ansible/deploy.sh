#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

ansible_namespace=aap
ansible_instance_name=aap

kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready ansibleautomationplatforms

ansible_hub_bucket_name=ansible-automation-hub
ensure_bucket ${ansible_hub_bucket_name} ${ansible_namespace}

export S3_REGION=${S3_REGION:-''}

apply_kustomize_dir ${this_dir}/operand

echo "Awaiting successful deployment. This may take a while...."

oc wait --for condition=Successful=true aap \
    ${ansible_instance_name} -n ${ansible_namespace}
