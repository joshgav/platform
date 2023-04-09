#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

# RHSSO operator can only target a single namespace
export KEYCLOAK_NAMESPACE=${1:-keycloak}

echo "INFO: install operator subscription for Keycloak"
apply_kustomize_dir ${this_dir}/operator
await_resource_ready "keycloak"

export KEYCLOAK_USER_SECRET=${KEYCLOAK_USER_SECRET:-supersecret}
apply_kustomize_dir ${this_dir}/local

## verify keycloak is ready
keycloak_status="false"
while [[ "${keycloak_status}" != "true" ]]; do
    keycloak_status=$(oc get keycloaks.keycloak.org main -n ${KEYCLOAK_NAMESPACE} -o json | \
                        jq -r '.status.ready')
    if [[ ${keycloak_status} != 'true' ]]; then
        echo "INFO: awaiting keycloak readiness"
        sleep 2
    else
        echo "INFO: keycloak ready"
    fi
done

## verify keycloak realm is ready
realm_status="false"
while [[ "${realm_status}" != "true" ]]; do
    realm_status=$(oc get keycloakrealms.keycloak.org main -n ${KEYCLOAK_NAMESPACE} -o json | \
                        jq -r '.status.ready')
    if [[ ${realm_status} != 'true' ]]; then
        echo "INFO: awaiting keycloak realm readiness"
        sleep 2
    else
        echo "INFO: keycloak realm ready"
    fi
done
