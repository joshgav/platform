---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: acme
spec:
  acme:
    solvers:
    # https://cert-manager.io/docs/configuration/acme/dns01/
    - dns01:
        # https://cert-manager.io/docs/configuration/acme/dns01/google/
        cloudDNS:
          project: ${GCP_PROJECT_ID}
          serviceAccountSecretRef:
            name: clouddns-serviceaccount-secret
            key: key.json