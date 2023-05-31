#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

# deploy operator
namespace=minio-operator
apply_kustomize_dir ${this_dir}/operator
await_resource_ready 'minio\.min\.io'
oc adm policy -n ${namespace} add-scc-to-user --serviceaccount minio-operator nonroot-v2
oc adm policy -n ${namespace} add-scc-to-user --serviceaccount console-sa nonroot-v2

# deploy tenant
tenant_namespace=minio-tenant-1
ensure_namespace ${tenant_namespace}
oc config set-context --current --namespace ${tenant_namespace}
oc adm policy -n ${tenant_namespace} add-scc-to-user --serviceaccount default nonroot-v2
apply_kustomize_dir ${this_dir}/tenant
