apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  name: ${MACHINESET_NAME}
  namespace: openshift-machine-api
  labels:
    machine.openshift.io/cluster-api-cluster: ${INFRASTRUCTURE_NAME}
    machine.openshift.io/cluster-api-machine-role: infra
    machine.openshift.io/cluster-api-machine-type: infra
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: ${INFRASTRUCTURE_NAME}
      machine.openshift.io/cluster-api-machineset: ${MACHINESET_NAME}
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: ${INFRASTRUCTURE_NAME}
        machine.openshift.io/cluster-api-machine-role: infra
        machine.openshift.io/cluster-api-machine-type: infra
        machine.openshift.io/cluster-api-machineset: ${MACHINESET_NAME}
    spec:
      # taints:
      # - effect: NoSchedule
      #   key: node.ocs.openshift.io/storage
      #   value: "true"
      metadata:
        labels:
          node-role.kubernetes.io/worker: ""
          node-role.kubernetes.io/infra: ""
          node-role.kubernetes.io: infra
          cluster.ocs.openshift.io/openshift-storage: ""
      providerSpec:
        value:
          apiVersion: machine.openshift.io/v1beta1
          kind: AWSMachineProviderConfig
          ami:
            id: ${RHCOS_AMI_ID}
          instanceType: m6i.2xlarge
          tags:
          - name: kubernetes.io/cluster/${INFRASTRUCTURE_NAME}
            value: owned
          blockDevices:
          - ebs:
              encrypted: true
              iops: 0
              kmsKey:
                arn: ""
              volumeSize: 120
              volumeType: gp3
          credentialsSecret:
            name: ${CLOUD_CREDENTIALS_SECRET_NAME}
          userDataSecret:
            name: worker-user-data
          deviceIndex: 0
          iamInstanceProfile:
            id: ${INFRASTRUCTURE_NAME}-worker-profile
          metadataServiceOptions: {}
          placement:
            availabilityZone: ${AWS_ZONE}
            region: ${AWS_REGION}
          securityGroups:
          - filters:
            - name: tag:Name
              values:
              - ${INFRASTRUCTURE_NAME}-worker-sg
          subnet:
            filters:
            - name: tag:Name
              values:
              - ${INFRASTRUCTURE_NAME}-private-${AWS_ZONE}
