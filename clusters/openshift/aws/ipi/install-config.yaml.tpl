# schema: https://github.com/openshift/installer/blob/master/pkg/types/installconfig.go
apiVersion: v1
metadata:
  name: ${OPENSHIFT_CLUSTER_NAME}
baseDomain: ${OPENSHIFT_BASE_DOMAIN}
controlPlane:
  name: master
  architecture: amd64
  hyperthreading: Enabled
  replicas: 3
compute:
- name: worker
  architecture: amd64
  hyperthreading: Enabled
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
    region: ${AWS_REGION}
    defaultMachinePlatform:
      type: m7i-flex.2xlarge
publish: External
pullSecret: '${OPENSHIFT_PULL_SECRET}'
sshKey: '${SSH_PUBLIC_KEY}'