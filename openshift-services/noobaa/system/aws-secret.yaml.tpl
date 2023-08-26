apiVersion: v1
kind: Secret
metadata:
  name: noobaa-aws-cloud-creds-secret
  namespace: noobaa
stringData:
  aws_access_key_id: ${AWS_ACCESS_KEY_ID}
  aws_secret_access_key: ${AWS_SECRET_ACCESS_KEY}