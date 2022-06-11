#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

namespace=app
oc create namespace ${namespace} 2> /dev/null || true

cat ${root_dir}/config/apiserver/spring-apiserver/kustomization.yaml.tpl | envsubst > ${root_dir}/config/apiserver/spring-apiserver/kustomization.yaml
trap "rm -f ${root_dir}/config/apiserver/spring-apiserver/kustomization.yaml" EXIT

temp_dir=${root_dir}/temp
mkdir -p ${temp_dir}

kustomize build ${root_dir}/config/apiserver/spring-apiserver | tee ${temp_dir}/spring-apiserver.yaml | kubectl apply -n ${namespace} -f -
