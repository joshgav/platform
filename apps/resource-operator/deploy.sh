#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

operator_name=resource-operator

export IMAGE_TAG_BASE=quay.io/joshgav/${operator_name}
export IMG=${IMAGE_TAG_BASE}:latest
export VERSION=latest

pushd ${this_dir}/${operator_name}
if [[ -z "${UNDEPLOY_OPERATOR}" ]]; then
    make deploy
    kubectl apply -f ${this_dir}/base/exampleresource.yaml
else
    kubectl delete -f ${this_dir}/base/exampleresource.yaml
    make undeploy
fi
popd
