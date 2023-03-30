[
  {
    "ParameterKey": "InfrastructureName", 
    "ParameterValue": "${INFRASTRUCTURE_NAME}" 
  },
  {
    "ParameterKey": "RhcosAmi", 
    "ParameterValue": "${REGIONAL_RHCOS_AMI_ID}" 
  },
  {
    "ParameterKey": "Subnet", 
    "ParameterValue": "${PRIVATE_SUBNET_01}" 
  },
  {
    "ParameterKey": "WorkerSecurityGroupId", 
    "ParameterValue": "${WORKER_SG_ID}" 
  },
  {
    "ParameterKey": "IgnitionLocation", 
    "ParameterValue": "https://api-int.${CLUSTER_NAME}.${BASE_DOMAIN}:22623/config/worker" 
  },
  {
    "ParameterKey": "CertificateAuthorities", 
    "ParameterValue": "${CA}" 
  },
  {
    "ParameterKey": "WorkerInstanceProfileName", 
    "ParameterValue": "${WORKER_INSTANCE_PROFILE}" 
  },
  {
    "ParameterKey": "WorkerInstanceType", 
    "ParameterValue": "m6i.large" 
  }
]