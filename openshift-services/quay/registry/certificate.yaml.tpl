---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${quay_certificate_name}
  namespace: quay
spec:
  secretName: ${quay_certificate_secret_name}
  commonName: registry-quay-quay.apps.ipi.aws.joshgav.com
  dnsNames:
  - ${quay_server_name}
  - registry-quay-quay.apps.ipi.aws.joshgav.com
  subject:
    organizationalUnits:
    - kubernetes
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: acme
    kind: ClusterIssuer
    group: cert-manager.io