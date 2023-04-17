apiVersion: v1
kind: Secret
metadata:
  name: minio-root-creds
type: Opaque
stringData:
  accesskey: ${USER_ACCESS_KEY_ID}
  secretkey: ${USER_SECRET_ACCESS_KEY}