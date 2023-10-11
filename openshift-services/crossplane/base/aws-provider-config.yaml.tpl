---
# AWS credentials secret
apiVersion: v1
kind: Secret
metadata:
  name: aws-creds
  namespace: crossplane-system
type: Opaque
# stringData:
#   credentials: '${aws_creds}'
data:
  credentials: '${aws_creds_encoded}'
---
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
  namespace: crossplane-system
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: credentials