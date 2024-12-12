# https://docs.openshift.com/container-platform/4.17/security/certificates/api-server.html
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: openshift-apiserver
  namespace: openshift-config
spec:
  commonName: 'api.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
  dnsNames:
    - 'api.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
  secretName: openshift-apiserver-keypair
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
