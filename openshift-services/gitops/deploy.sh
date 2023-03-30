#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready argocd

oc adm policy add-cluster-role-to-user cluster-admin -n openshift-gitops \
    --serviceaccount openshift-gitops-argocd-application-controller

kustomize build ${this_dir}/base | oc apply -f -
