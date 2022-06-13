#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh

operator_name=openshift-gitops-operator
operator_namespace=openshift-operators

echo "INFO: install gitops operator"
create_subscription ${operator_name} ${operator_namespace}

kustomize build ${this_dir}/base | oc apply -f -
