apiVersion: ocs.openshift.io/v1
kind: StorageCluster
metadata:
  name: ocs-storagecluster
  namespace: openshift-storage
spec:
  resourceProfile: balanced
  storageDeviceSets:
    - name: ocs-deviceset
      dataPVCTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 2Ti
          storageClassName: ${default_sc}
          volumeMode: Block
      count: 1
      replica: 3