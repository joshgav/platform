#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export HELM_REPO_URL=https://charts.external-secrets.io/
export HELM_REPO_NAME=external-secrets
export HELM_INSTALL_NAME=eso
export HELM_INSTALL_NAMESPACE=eso
export HELM_CHART_NAME=${HELM_REPO_NAME}/external-secrets

helm repo add ${HELM_REPO_NAME} ${HELM_REPO_URL}
helm repo update

helm install ${HELM_INSTALL_NAME} ${HELM_CHART_NAME} \
    --namespace ${HELM_INSTALL_NAMESPACE} \
    --create-namespace
