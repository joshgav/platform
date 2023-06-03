#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=openshift-mta
kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready tackles

ensure_namespace ${namespace}
apply_kustomize_dir ${this_dir}/operand
