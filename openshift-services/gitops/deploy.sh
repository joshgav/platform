#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

kustomize build ${this_dir}/operator | oc apply -f -
await_resource_ready argocd

ready=0
while [[ ${ready} == 0 ]]; do
    oc get namespace openshift-gitops > /dev/null
    if [[ $? == 0 ]]; then ready=1; else ready=0; sleep 2; fi
done

kustomize build ${this_dir}/gitops | oc apply -f -
