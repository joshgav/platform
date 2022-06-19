#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/olm-subscriptions.sh

namespace=keycloak
kubectl create namespace ${namespace} 2> /dev/null || true
create_local_operatorgroup ${namespace}

echo "INFO: install keycloak operator via OLM"
if is_openshift; then
    operator_name=rhsso-operator
else
    operator_name=keycloak-operator
fi
create_subscription ${operator_name} ${namespace}

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    kubectl api-resources | grep keycloak &> /dev/null
    ready=$?
done

source ${this_dir}/msad/.env
cat ${this_dir}/msad/kustomization.yaml.tpl | envsubst > ${this_dir}/msad/kustomization.yaml
trap "rm -f ${this_dir}/msad/kustomization.yaml" EXIT

kustomize build ${this_dir}/msad | kubectl apply -n ${namespace} -f -
