apiVersion: v1
kind: Secret
metadata:
  name: azure-credential
  namespace: openshift-lightspeed
type: Opaque
stringData:
  apitoken: ${AZURE_OPENAI_API_KEY}