#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/requirements.sh
install_argocd_cli

namespace=argocd
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace ${namespace}

cm_keypair_name=argocd-tls-keypair
kubectl get secret ${cm_keypair_name} &> /dev/null
if [[ $? == 0 ]]; then
    echo "INFO: found cert-manager provisioned keypair, will use that"
    kustomize_base=cert-manager
else
    echo "INFO: using default argocd-secret"
    kustomize_base=base
fi

echo "INFO: install argocd"
kustomize build ${this_dir}/${kustomize_base} | kubectl apply -n ${namespace} -f -

argocd login --core

echo "INFO: initial admin secret:"
kubectl get secrets argocd-initial-admin-secret -n ${namespace} -o json | jq -r '.data.password | @base64d'