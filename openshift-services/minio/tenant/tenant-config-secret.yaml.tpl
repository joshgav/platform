apiVersion: v1
kind: Secret
metadata:
  name: minio-tenant-config
type: Opaque
stringData:
  config.env: |-
    export MINIO_ROOT_USER="minio"
    export MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD}"
    export MINIO_STORAGE_CLASS_STANDARD="EC:2"
    export MINIO_BROWSER="on"