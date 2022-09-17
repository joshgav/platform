#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/kubernetes.sh
operator_name=advanced-cluster-management
operator_namespace=open-cluster-management

# oc create namespace ${namespace}
# create_local_operatorgroup ${namespace}

echo
echo "INFO: install acm operator"
create_subscription ${operator_name} ${operator_namespace}

kustomize build ${this_dir}/assisted | oc apply -f -
