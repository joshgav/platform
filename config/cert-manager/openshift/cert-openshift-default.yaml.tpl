# https://docs.openshift.com/container-platform/4.6/security/certificates/replacing-default-ingress-certificate.html
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: openshift-default
  namespace: openshift-ingress
spec:
  commonName: '*.apps.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
  dnsNames:
    - '*.apps.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
  secretName: openshift-default-keypair
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
