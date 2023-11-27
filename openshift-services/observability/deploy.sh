#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=openshift-metrics
ensure_namespace ${namespace} true

create_subscription cluster-observability-operator
await_resource_ready monitoringstacks

apply_kustomize_dir ${this_dir}/resources
