apiVersion: v1
kind: Secret
metadata:
  name: awssm-secret
type: Opaque
stringData:
  access-key-id: ${AWS_ACCESS_KEY_ID}
  secret-access-key: ${AWS_SECRET_ACCESS_KEY}
