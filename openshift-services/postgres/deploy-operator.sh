#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

operator_api_resource='postgresql.cnpg.io'

## Subscription via OLM
echo "INFO: installing operator for API group ${operator_api_resource}"
kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready "${operator_api_resource}"
oc adm policy add-scc-to-user -n cnpg-system --serviceaccount cnpg-manager nonroot-v2
