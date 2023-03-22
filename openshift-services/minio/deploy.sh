#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

tenant_namespace=minio-tenant

apply_kustomize_dir ${this_dir}/operator
await_resource_ready 'minio\.min\.io'

ensure_namespace ${tenant_namespace}
oc config set-context --current --namespace ${tenant_namespace}
oc adm policy add-scc-to-user --serviceaccount default nonroot

apply_kustomize_dir ${this_dir}/storage
