#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

create_subscription rh-service-binding-operator
await_resource_ready "servicebinding"
