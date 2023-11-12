apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: ${gateway_name}
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller