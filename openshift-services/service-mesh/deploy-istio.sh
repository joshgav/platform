#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

apply_kustomize_dir ${this_dir}/istio-operator
await_resource_ready istiocni
apply_kustomize_dir ${this_dir}/kiali-operator
await_resource_ready kiali

apply_kustomize_dir ${this_dir}/istio-configuration
apply_kustomize_dir ${this_dir}/kiali-configuration
