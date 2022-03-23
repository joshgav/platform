---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: acme
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: joshgavant@gmail.com
    privateKeySecretRef:
      name: letsencrypt-issuer-keypair
    solvers:
    # https://cert-manager.io/docs/configuration/acme/http01/
    - http01:
        ingress:
          class: openshift-default
    # https://cert-manager.io/docs/configuration/acme/dns01/
    - dns01:
        # https://cert-manager.io/docs/configuration/acme/dns01/route53/
        route53:
          region: ${AWS_REGION}
          accessKeyID: ${AWS_ACCESS_KEY_ID}
          secretAccessKeySecretRef:
            name: route53-access-key
            key: AccessKeySecret
          hostedZoneID: ${zone_id}