apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${KEYCLOAK_NAMESPACE}
resources:
- ./keycloak.yaml
- ./realm.yaml
