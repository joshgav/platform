apiVersion: v1
kind: Secret
metadata:
  name: ansible-automation-hub-s3
stringData:
  s3-access-key-id: ${S3_ACCESS_KEY_ID}
  s3-secret-access-key: ${S3_SECRET_ACCESS_KEY}
  s3-bucket-name: ${S3_BUCKET_NAME}
  s3-region: ${S3_REGION}
  s3-endpoint: ${S3_ENDPOINT_URL}
