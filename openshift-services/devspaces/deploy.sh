#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready 'checluster'

kustomize build ${this_dir}/operand | oc apply -f -

cat ${this_dir}/resources/github-secret.template.yaml | envsubst | oc apply -f -
