apiVersion: v1
kind: Secret
metadata:
    name: route53-access-key
    namespace: cert-manager
stringData:
    AccessKeyID: ${AWS_ACCESS_KEY_ID}
    AccessKeySecret: ${AWS_SECRET_ACCESS_KEY}