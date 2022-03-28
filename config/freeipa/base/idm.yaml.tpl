---
apiVersion: idmocp.redhat.com/v1alpha1
kind: IDM
metadata:
  name: idm
spec:
  host: freeipa.apps.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}
  passwordSecret: idm-password
  resources:
    requests:
      cpu: "1"
      memory: "1Gi"
    limits:
      cpu: "3"
      memory: "4Gi"
  volumeClaimTemplate:
    resources:
      requests:
        storage: 10Gi
    volumeMode: Filesystem
    accessModes:
      - ReadWriteOnce