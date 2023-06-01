apiVersion: v1
kind: Secret
metadata:
  name: minio-tenant
type: Opaque
stringData:
  CONSOLE_ACCESS_KEY: ${USER_USERNAME}
  CONSOLE_SECRET_KEY: ${USER_PASSWORD}
