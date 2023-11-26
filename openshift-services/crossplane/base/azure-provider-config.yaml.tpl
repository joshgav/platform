---
# AWS credentials secret
apiVersion: v1
kind: Secret
metadata:
  name: azure-creds
  namespace: crossplane-system
type: Opaque
stringData:
  credentials: |
    ${azure_creds}
---
apiVersion: azure.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
  namespace: crossplane-system
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: azure-creds
      key: credentials