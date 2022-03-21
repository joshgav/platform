#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh

# namespace=app
# oc create namespace ${namespace}
# create_local_operatorgroup ${namespace}

echo
echo "INFO: install crunchy-postgres-operator"
create_subscription crunchy-postgres-operator openshift-operators

kustomize build ${root_dir}/config/db | oc apply -f -
