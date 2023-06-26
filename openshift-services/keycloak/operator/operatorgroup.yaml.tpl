apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
    name: ${keycloak_namespace}-group
spec:
    targetNamespaces:
      - ${keycloak_namespace}