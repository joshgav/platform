apiVersion: keycloak.org/v1alpha1
kind: Keycloak
metadata:
  name: ${cluster_keycloak_name}
  labels:
    keycloak: ${cluster_keycloak_name}
spec:
  instances: 1
  externalAccess:
    enabled: true