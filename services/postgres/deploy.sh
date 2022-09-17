#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

echo "INFO: install crunchy-postgres-operator via OLM"
if is_openshift; then
    operator_name=crunchy-postgres-operator
else
    operator_name=postgresql
fi
create_subscription ${operator_name}
await_resource_ready PostgresCluster

## also create an instance:
# namespace=app
# kubectl create namespace ${namespace} &> /dev/null || true
# kustomize build ${this_dir}/base | kubectl apply -n ${namespace} -f -
