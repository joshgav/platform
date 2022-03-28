apiVersion: instana.io/v1
kind: InstanaAgent
metadata:
  name: instana-agent
  namespace: instana-agent
spec:
  agent:
    endpointHost: ingress-coral-saas.instana.io
    endpointPort: "443"
    key: ${INSTANA_API_KEY}
    downloadKey: ${INSTANA_DOWNLOAD_KEY}
    configuration:
      autoMountConfigEntries: true
  cluster:
    name: ${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}
  openshift: true
  rbac:
    create: true
  service:
    create: true
  opentelemetry:
    enabled: true
  prometheus: {}
