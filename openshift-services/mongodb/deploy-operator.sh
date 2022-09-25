#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

operator_name=mongodb
operator_namespace=mongodb

ensure_helm_repo mongodb https://mongodb.github.io/helm-charts

helm upgrade --install ${operator_name} mongodb/community-operator \
    --namespace "${operator_namespace}" --create-namespace \
    --set 'operator.watchNamespace=*'

oc adm policy add-scc-to-user anyuid -n ${operator_namespace} -z mongodb-kubernetes-operator
oc apply -f ${this_dir}/base/role.yaml
