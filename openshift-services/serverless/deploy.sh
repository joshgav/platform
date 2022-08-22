#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/yaml.sh
source ${root_dir}/lib/olm.sh

apply_kustomize_dir ${this_dir}/operator
await_resource_ready "serving"

ready=1
while [[ ${ready} != 0 ]]; do
    kubectl get namespace knative-eventing &> /dev/null
    ready=$?
    if [[ ${ready} != 0 ]]; then
        echo "INFO: awaiting knative namespace creation"
        sleep 2
    else
        echo "INFO: knative namespaces are ready"
    fi
done

apply_kustomize_dir ${this_dir}/knative
