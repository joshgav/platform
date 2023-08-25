#! /usr/bin/env bash

## NOTE: this script expects KUBECONFIG context to point to secured cluster already
##       but roxctl uses $ROX_ENDPOINT env var to point to central cluster

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

# export for use in kustomization
export cluster_name=${SECURED_CLUSTER_NAME:-local-cluster}

## set central endpoint
if [[ "${cluster_name}" == "local-cluster" ]]; then
    export central_endpoint='central.stackrox.svc:443'
elif [[ -n "${ROX_ENDPOINT}" ]]; then
    export central_endpoint=${ROX_ENDPOINT}
else
    apps_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r '.spec.domain')
    export central_endpoint=central-stackrox.${apps_domain}:443
fi
echo "INFO: using Rox endpoint: ${central_endpoint}"

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
    echo "WARN: init-bundle for ${cluster_name} already exists"
    cluster_exists="true"
fi
if [[ "${cluster_exists}" == "true" && -n "${RECREATE_CLUSTER}" ]]; then
    roxctl central init-bundles revoke ${cluster_name} \
        --insecure-skip-tls-verify
    rm ${cluster_name}-init-bundle.yaml
elif [[ "${cluster_exists}" == "true" ]]; then
    exit
fi

## generate secured cluster
echo "INFO: generate init-bundles for cluster: ${cluster_name}"
roxctl central init-bundles generate ${cluster_name} --output-secrets ${cluster_name}-init-bundle.yaml \
    --insecure-skip-tls-verify

if [[ "${cluster_name}" == "local-cluster" ]]; then
    echo "INFO: installing local secured cluster"
    ${this_dir}/deploy-operator.sh
    oc apply -n stackrox -f ${cluster_name}-init-bundle.yaml
    apply_kustomize_dir ${this_dir}/securedcluster
fi
