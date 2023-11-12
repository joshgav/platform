#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export gateway_namespace=envoy-gateway-system
export gateway_name=main-gateway
export envoy_gateway_version='v0.0.0-latest'

ensure_namespace ${gateway_namespace} true

helm upgrade --install ${gateway_name} oci://docker.io/envoyproxy/gateway-helm --version ${envoy_gateway_version}
kubectl wait --timeout=5m deployment/envoy-gateway --for=condition=Available

apply_kustomize_dir ${this_dir}/resources
apply_kustomize_dir ${this_dir}/sample
