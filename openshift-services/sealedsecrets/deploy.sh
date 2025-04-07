#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export HELM_REPO_URL=https://bitnami-labs.github.io/sealed-secrets
export HELM_REPO_NAME=sealed-secrets
export HELM_INSTALL_NAME=sealed-secrets
export HELM_INSTALL_NAMESPACE=sealed-secrets
export HELM_CHART_NAME=${HELM_REPO_NAME}/sealed-secrets

helm repo add ${HELM_REPO_NAME} ${HELM_REPO_URL}
helm repo update

## set securityContext values to null (defaults) for OpenShift compat
helm install ${HELM_INSTALL_NAME} ${HELM_CHART_NAME} \
    --namespace ${HELM_INSTALL_NAMESPACE} \
    --create-namespace \
    --set 'podSecurityContext.fsGroup=null' \
    --set 'containerSecurityContext.runAsUser=null'
