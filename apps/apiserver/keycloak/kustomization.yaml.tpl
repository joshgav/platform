apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base-k8s
# - ../base-openshift
- ./spring-apiserver-client.yaml

patchesStrategicMerge:
- ./deployment.yaml

patches:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: spring-apiserver
  patch: |
    [{
        "op": "replace",
        "path": "/spec/template/spec/containers/0/env/0/value",
        "value": "${KEYCLOAK_AUTH_ENDPOINT}"
    }]
- target:
    group: keycloak.org
    version: v1alpha1
    kind: KeycloakClient
    name: spring-apiserver
  patch: |
    [{
        "op": "replace",
        "path": "/spec/client/redirectUris/0",
        "value": "${APISERVER_REDIRECT_URI}"
    }]