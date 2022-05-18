#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh
operator_name=advanced-cluster-management
operator_namespace=open-cluster-management

# oc create namespace ${namespace}
# create_local_operatorgroup ${namespace}

echo
echo "INFO: install acm operator"
create_subscription ${operator_name} ${operator_namespace}

kustomize build ${root_dir}/config/acm/assisted | oc apply -f -
