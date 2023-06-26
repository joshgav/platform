apiVersion: keycloak.org/v1alpha1
kind: Keycloak
metadata:
  name: ${cluster_keycloak_name}
  labels:
    keycloak: ${cluster_keycloak_name}
spec:
  instances: 2
  externalAccess:
    enabled: true
  keycloakDeploymentSpec:
    podannotations:
      instrumentation.opentelemetry.io/inject-java: "true"