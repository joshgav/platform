apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${KEYCLOAK_NAMESPACE}
resources:
- namespace.yaml
- operatorgroup.yaml
- subscription.yaml