#! /usr/bin/env bash

## Based on https://istio.io/latest/docs/examples/bookinfo/

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

## kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=v1.0.0" | kubectl apply -f -
## istioctl install --set values.pilot.env.PILOT_ENABLE_ALPHA_GATEWAY_API=true --set profile=minimal -y

namespace=istio-bookinfo
ensure_namespace ${namespace} true
kubectl label namespace ${namespace} istio-injection=enabled
ensure_helm_repo istio https://istio-release.storage.googleapis.com/charts
helm install istio-ingressgateway istio/gateway -f https://raw.githubusercontent.com/istio/istio/master/manifests/charts/gateway/openshift-values.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/networking/bookinfo-gateway.yaml

exit

# kubectl wait --for=condition=programmed gateways.gateway.networking.k8s.io bookinfo-gateway
# export GATEWAY_ADDRESS=$(kubectl get gateways.gateway.networking.k8s.io bookinfo-gateway -o jsonpath='{.status.addresses[0].value}')
# export GATEWAY_PORT=$(kubectl get gateways.gateway.networking.k8s.io bookinfo-gateway -o jsonpath='{.spec.listeners[?(@.name=="http")].port}')
# export GATEWAY_HOSTNAME=${GATEWAY_ADDRESS}:${GATEWAY_PORT}

GATEWAY_HOSTNAME=$(kubectl get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GATEWAY_PORT=$(kubectl get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

curl -s "http://${GATEWAY_HOSTNAME}/productpage" | grep -o "<title>.*</title>"
