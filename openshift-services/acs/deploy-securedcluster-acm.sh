#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

cluster_name=central
export managed_namespace=stackrox-managed

## install roxctl CLI
if ! which roxctl &> /dev/null; then
    echo "INFO: installing roxctl"
    ${this_dir}/install-roxctl.sh
else
    echo "INFO: found existing roxctl"
fi
echo "INFO: roxctl version"
roxctl version

## verify login
echo "INFO: verify login"
roxctl central whoami --insecure-skip-tls-verify

## generate init-bundle for secured cluster
cluster_exists="false"
roxctl central init-bundles list --insecure-skip-tls-verify | grep -q "^${cluster_name}\b"
if [[ $? == 0 ]]; then
    cluster_exists="true"
fi
if [[ "${cluster_exists}" == "true" && -n "${RECREATE_CLUSTER}" ]]; then
    echo "INFO: attempting to remove existing bundle"
    roxctl central init-bundles revoke ${cluster_name} --insecure-skip-tls-verify
    rm ${cluster_name}-init-bundle.yaml
elif [[ "${cluster_exists}" == "true" ]]; then
    echo "WARN: init-bundle for ${cluster_name} already exists, exiting"
    exit
fi

## generate init-bundle for secured cluster
roxctl central init-bundles generate ${cluster_name} --output-secrets ${cluster_name}-init-bundle.yaml \
    --insecure-skip-tls-verify
oc apply --namespace ${managed_namespace} -f ${cluster_name}-init-bundle.yaml
apply_kustomize_dir ${this_dir}/securedcluster-acm
