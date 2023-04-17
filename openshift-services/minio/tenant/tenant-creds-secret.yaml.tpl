apiVersion: v1
kind: Secret
metadata:
  name: minio-tenant
type: Opaque
stringData:
  CONSOLE_ACCESS_KEY: ${USER_ACCESS_KEY_ID}
  CONSOLE_SECRET_KEY: ${USER_SECRET_ACCESS_KEY}
