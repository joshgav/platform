apiVersion: v1
kind: Secret
metadata:
    name: clouddns-serviceaccount-secret
stringData:
    key.json: |
        ${GCP_SERVICEACCOUNT_KEY}
    