apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
  namespace: open-cluster-management-observability
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: ${S3_BUCKET_NAME}
      endpoint: ${S3_ENDPOINT_URL}
      insecure: false
      access_key: ${S3_ACCESS_KEY_ID}
      secret_key: ${S3_SECRET_ACCESS_KEY}