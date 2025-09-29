#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

operator_name=advanced-cluster-management
operator_namespace=open-cluster-management
# operator_version=release-2.8

ensure_namespace ${operator_namespace} true
apply_kustomize_dir ${this_dir}/operator
await_resource_ready multiclusterhub

kustomize build ${this_dir}/base | oc apply -f -
await_resource_ready managedclustersetbinding

oc get argocds.argoproj.io -n openshift-gitops openshift-gitops &> /dev/null
if [[ $? == 0 ]]; then
    echo "INFO: binding ACM to hub cluster's ArgoCD instance"
    kustomize build ${this_dir}/argocd | oc apply -f -
fi
