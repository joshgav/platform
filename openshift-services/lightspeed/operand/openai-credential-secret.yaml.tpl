apiVersion: v1
kind: Secret
metadata:
  name: openai-credential
  namespace: openshift-lightspeed
type: Opaque
stringData:
  apitoken: ${OPENAI_API_KEY}