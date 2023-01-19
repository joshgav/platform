#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

create_subscription opentelemetry-product
await_resource_ready opentelemetrycollectors

create_subscription jaeger-product
await_resource_ready jaegers

apply_kustomize_dir ${this_dir}/collector
