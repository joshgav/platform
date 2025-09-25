---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: acme-joshgav-com
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: joshgavant@gmail.com
    privateKeySecretRef:
      name: letsencrypt-issuer-keypair-joshgav-com
    solvers:
    - dns01:
        route53:
          region: ${AWS_REGION}
          accessKeyID: ${AWS_ACCESS_KEY_ID}
          secretAccessKeySecretRef:
            name: route53-access-key-joshgav-com
            key: AccessKeySecret
          hostedZoneID: ${ROUTE53_ZONE_ID}