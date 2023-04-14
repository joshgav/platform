#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

apply_kustomize_dir ${this_dir}/operator
await_resource_ready "hyperconverged"

export infra_name=$(oc get infrastructures.config.openshift.io cluster --output json | jq -r '.status.infrastructureName')
cat ${this_dir}/operand/machineset.yaml | envsubst '${infra_name}' | kubectl apply -f -

kubectl apply -f ${this_dir}/operand/hyperconverged.yaml
