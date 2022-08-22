apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
    name: keycloak-group
spec:
    targetNamespaces:
      - ${KEYCLOAK_NAMESPACE}