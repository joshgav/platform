# schema: https://github.com/openshift/installer/blob/master/pkg/types/installconfig.go
apiVersion: v1
metadata:
  name: ${OPENSHIFT_CLUSTER_NAME}
baseDomain: ${OPENSHIFT_BASE_DOMAIN}
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
networking:
  networkType: OVNKubernetes
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: us-east-2
publish: External
pullSecret: '${OPENSHIFT_PULL_SECRET}'
sshKey: '${OPENSHIFT_SSH_PUBLIC_KEY}'

# baselineCapabilitySet: vCurrent
# additionalEnabledCapabilities:
#   - openshift-samples
