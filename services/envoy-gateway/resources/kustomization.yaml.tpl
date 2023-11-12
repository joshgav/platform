apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${gateway_namespace}
resources:
- gatewayclass.yaml
- gateway.yaml