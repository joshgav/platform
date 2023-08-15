#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

operator_name=advanced-cluster-management
operator_namespace=open-cluster-management
# operator_version=release-2.8

ensure_namespace ${operator_namespace} true
create_local_operatorgroup ${operator_namespace}

echo "INFO: install acm operator"
create_subscription ${operator_name} ${operator_namespace}

kustomize build ${this_dir}/base | oc apply -f -
