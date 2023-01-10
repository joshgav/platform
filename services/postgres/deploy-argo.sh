#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

# TODO: adjust for OpenShift
kubectl get deployments -n argocd argocd-server &> /dev/null
if [[ $? == 0 ]]; then
    kubectl apply -f ${this_dir}/application.yaml
else
    echo "ERROR: ArgoCD is not installed, cannot deploy Argo app"
    exit 2
fi
