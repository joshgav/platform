apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: joshgav-com
  namespace: openshift-ingress
spec:
  commonName: '*.joshgav.com'
  dnsNames:
    - '*.joshgav.com'
  secretName: joshgav-com-keypair
  issuerRef:
    name: acme-joshgav-com
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
