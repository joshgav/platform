#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
config_dir=${this_dir}
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

namespace=emissary-ingress
repo_name=datawire
chart_name=emissary-ingress
crd_version=2.3.1

# ensure datawire chart repo is configured
helm repo list | grep "^${repo_name}" &> /dev/null || helm repo add "${repo_name}" https://www.getambassador.io
helm repo update

# hint to extrapolate default values.yaml
# helm show values ${repo_name}/${chart_name} > ${root_dir}/temp/${chart_name}-values.yaml

# ensure namespace is created switch to it
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace ${namespace}

# per these instructions: https://www.getambassador.io/docs/emissary/latest/topics/install/helm/#install-with-helm-1
kubectl apply -f https://app.getambassador.io/yaml/emissary/${crd_version}/emissary-crds.yaml
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system

helm upgrade --install emissary-ingress ${repo_name}/${chart_name} \
    --namespace ${namespace} \
    --values ${config_dir}/values.yaml
