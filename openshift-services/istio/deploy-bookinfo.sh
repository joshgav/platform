#! /usr/bin/env bash

## Based on https://istio.io/latest/docs/examples/bookinfo/

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

## kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=v1.0.0" | kubectl apply -f -
## istioctl install --set values.pilot.env.PILOT_ENABLE_ALPHA_GATEWAY_API=true --set profile=minimal -y

namespace=bookinfo
ensure_namespace ${namespace} true

kubectl label namespace ${namespace} istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/bookinfo/gateway-api/bookinfo-gateway.yaml

kubectl wait --for=condition=programmed gateways.gateway.networking.k8s.io bookinfo-gateway

export GATEWAY_ADDRESS=$(kubectl get gateways.gateway.networking.k8s.io bookinfo-gateway -o jsonpath='{.status.addresses[0].value}')
export GATEWAY_PORT=$(kubectl get gateways.gateway.networking.k8s.io bookinfo-gateway -o jsonpath='{.spec.listeners[?(@.name=="http")].port}')
export GATEWAY_HOSTNAME=${GATEWAY_ADDRESS}:${GATEWAY_PORT}

curl -s "http://${GATEWAY_HOSTNAME}/productpage" | grep -o "<title>.*</title>"
