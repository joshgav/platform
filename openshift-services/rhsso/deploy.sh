#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/olm-subscriptions.sh

namespace=app

source ${this_dir}/msad/.env
cat ${this_dir}/msad/kustomization.yaml.tpl | envsubst > ${this_dir}/msad/kustomization.yaml
trap "rm -f ${this_dir}/msad/kustomization.yaml" EXIT

kustomize build ${this_dir}/msad | kubectl apply -n ${namespace} -f -
