#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh

namespace=app

echo
echo "INFO: install crunchy-postgres-operator"
create_subscription crunchy-postgres-operator openshift-operators

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    oc api-resources | grep postgres &> /dev/null
    ready=$?
done

kustomize build ${root_dir}/config/db/base | oc apply -n ${namespace} -f -
