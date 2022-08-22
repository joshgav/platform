#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/olm.sh

echo "INFO: install crunchy-postgres-operator via OLM"
if is_openshift; then
    operator_name=crunchy-postgres-operator
else
    operator_name=postgresql
fi
create_subscription ${operator_name}

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep postgres &> /dev/null
    ready=$?
done

# namespace=app
# kubectl create namespace ${namespace} &> /dev/null || true
# kustomize build ${this_dir}/base | kubectl apply -n ${namespace} -f -
