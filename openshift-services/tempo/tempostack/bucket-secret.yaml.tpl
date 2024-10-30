apiVersion: v1
kind: Secret
metadata:
  name: tempostack-bucket-secret
stringData:
  access_key_id: ${S3_ACCESS_KEY_ID}
  access_key_secret: ${S3_SECRET_ACCESS_KEY}
  bucket: ${S3_BUCKET_NAME}
  endpoint: ${S3_ENDPOINT_URL}