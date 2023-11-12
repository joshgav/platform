## Envoy Gateway

Enables use of Gateway API.

```bash
# test with NodePort
export ENVOY_SERVICE=$(kubectl get service -n envoy-gateway-system \
  --selector=gateway.envoyproxy.io/owning-gateway-namespace=${gateway_namespace},gateway.envoyproxy.io/owning-gateway-name=${gateway_name} \
  -o jsonpath='{.items[0].metadata.name}')
kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 8888:80 &
curl --verbose --header "Host: test.cluster1.joshgav.com" http://localhost:8888/get

## test with LoadBalancer
export ENVOY_SERVICE=$(kubectl get service -n envoy-gateway-system \
  --selector=gateway.envoyproxy.io/owning-gateway-namespace=${gateway_namespace},gateway.envoyproxy.io/owning-gateway-name=${gateway_name} \
  -o jsonpath='{.items[0].metadata.name}')
export GATEWAY_HOST=$(kubectl get service/${ENVOY_SERVICE} -n envoy-gateway-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl --verbose --header "Host: test.cluster1.joshgav.com" http://${GATEWAY_HOST}/get

## if DNS resolution works:
curl --verbose http://test.clusters1.joshgav.com/get
```