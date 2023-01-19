#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

if is_openshift; then
    argocd_namespace=openshift-gitops
    argocd_deployment=openshift-gitops-server
    kustomize_path=base
else
    argocd_namespace=argocd
    argocd_deployment=argocd-server
    kustomize_path=base
fi

kubectl get deployments -n ${argocd_namespace} ${argocd_deployment} &> /dev/null
if [[ $? == 0 ]]; then
    export argocd_namespace kustomize_path
    cat ${this_dir}/application.yaml | envsubst | kubectl apply -f -
else
    echo "ERROR: ArgoCD is not installed, cannot deploy Argo app"
    exit 2
fi
