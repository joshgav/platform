---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: acme
spec:
  acme:
    solvers:
    # https://cert-manager.io/docs/configuration/acme/dns01/
    - dns01:
        # https://cert-manager.io/docs/configuration/acme/dns01/route53/
        route53:
          region: ${AWS_REGION}
          accessKeyID: ${AWS_ACCESS_KEY_ID}
          secretAccessKeySecretRef:
            name: route53-access-key
            key: AccessKeySecret
          hostedZoneID: ${ROUTE53_ZONE_ID}