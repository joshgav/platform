#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/olm-subscriptions.sh

namespace=app
oc create namespace ${namespace} 2> /dev/null || true
create_local_operatorgroup ${namespace}

echo
echo "INFO: install rhsso-operator"
create_subscription rhsso-operator ${namespace}

ready=1
while [[ ${ready} != 0 ]]; do
    echo "INFO: awaiting readiness of operator"
    oc api-resources | grep keycloak &> /dev/null
    ready=$?
done

cat ${root_dir}/config/keycloak/msad/kustomization.yaml.tpl | envsubst > ${root_dir}/config/keycloak/msad/kustomization.yaml
trap "rm -f ${root_dir}/config/keycloak/msad/kustomization.yaml" EXIT

temp_dir=${root_dir}/temp
mkdir -p ${temp_dir}

kustomize build ${root_dir}/config/keycloak/msad | tee ${temp_dir}/keycloak-msad.yaml | kubectl apply -n ${namespace} -f -
