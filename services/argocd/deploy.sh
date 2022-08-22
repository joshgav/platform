#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/install.sh
install_argocd_cli

namespace=argocd
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace ${namespace}

kustomize build ${this_dir}/cert-manager | kubectl apply -n ${namespace} -f -

argocd login --core

echo "INFO: initial admin secret:"
kubectl get secrets argocd-initial-admin-secret -n ${namespace} -o json | jq -r '.data.password | @base64d'
