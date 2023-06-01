apiVersion: v1
kind: Secret
metadata:
  name: minio-root-creds
type: Opaque
stringData:
  accesskey: ${ROOT_ACCESS_KEY_ID}
  secretkey: ${ROOT_SECRET_ACCESS_KEY}