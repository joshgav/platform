apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: openshift-gateway-default
  namespace: openshift-ingress
spec:
  commonName: '*.gateway.apps.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
  dnsNames:
    - '*.gateway.apps.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
  secretName: openshift-gateway-default-keypair
  issuerRef:
    name: acme
    kind: ClusterIssuer
    group: cert-manager.io
  subject:
    organizationalUnits:
      - 'kubernetes'
  usages:
    - server auth
    - client auth
    - digital signature
    - key encipherment
    - signing
