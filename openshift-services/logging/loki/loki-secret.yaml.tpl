apiVersion: v1
kind: Secret
metadata:
  name: logging-loki-s3
  namespace: openshift-logging
stringData:
  access_key_id: ${S3_ACCESS_KEY_ID}
  access_key_secret: ${S3_SECRET_ACCESS_KEY}
  bucketnames: ${S3_BUCKET_NAME}
  endpoint: ${S3_ENDPOINT_URL}