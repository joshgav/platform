apiVersion: v1
kind: Secret
metadata:
    name: route53-access-key
stringData:
    AccessKeyID: ${AWS_ACCESS_KEY_ID}
    AccessKeySecret: ${AWS_SECRET_ACCESS_KEY}