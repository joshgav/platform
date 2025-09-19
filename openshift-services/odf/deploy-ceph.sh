#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

${this_dir}/deploy-operator.sh

## find default storage class
default_sc=$(oc get storageclasses.storage.k8s.io -ojson | \
    jq -r '.items[] | select(.metadata.annotations."storageclass.kubernetes.io/is-default-class" == "true") | .metadata.name')
export default_sc

apply_kustomize_dir ${this_dir}/ceph
