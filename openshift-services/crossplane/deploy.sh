#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

helm repo add ${CROSSPLANE_HELM_REPO_NAME} https://charts.crossplane.io/stable

helm upgrade --install crossplane ${CROSSPLANE_HELM_REPO_NAME}/crossplane \
    --namespace ${CROSSPLANE_SYSTEM_NAMESPACE} --create-namespace

oc adm policy add-scc-to-group anyuid -n ${CROSSPLANE_SYSTEM_NAMESPACE} system:serviceaccounts:${CROSSPLANE_SYSTEM_NAMESPACE}

## check logged in AWS user
aws sts get-caller-identity
export aws_creds_encoded=$(echo -e "[default]\naws_access_key_id = ${AWS_ACCESS_KEY_ID}\naws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" | base64 | tr -d "\n")

## check logged in Azure user
az ad signed-in-user show
export azure_creds=$(az ad sp create-for-rbac --name crossplane-system --json-auth --role Owner --scopes /subscriptions/${AZURE_SUBSCRIPTION_ID} | tr -d "\n")

apply_kustomize_dir ${this_dir}/base
