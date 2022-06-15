apiVersion: v1
kind: Secret
type: kubernetes.io/dockerconfigjson
metadata:
  name: quay-secret
  namespace: app
  annotations:
    tekton.dev/docker-0: https://quay.io
data:
  .dockerconfigjson: ${QUAY_DOCKERCONFIGJSON}