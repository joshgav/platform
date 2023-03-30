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
    "ParameterKey": "AutoRegisterDNS", 
    "ParameterValue": "yes" 
  },
  {
    "ParameterKey": "Master0Subnet", 
    "ParameterValue": "${PRIVATE_SUBNET_01}" 
  },
  {
    "ParameterKey": "Master1Subnet", 
    "ParameterValue": "${PRIVATE_SUBNET_01}" 
  },
  {
    "ParameterKey": "Master2Subnet", 
    "ParameterValue": "${PRIVATE_SUBNET_01}" 
  },
  {
    "ParameterKey": "MasterSecurityGroupId", 
    "ParameterValue": "${MASTER_SG_ID}"
  },
  {
    "ParameterKey": "IgnitionLocation", 
    "ParameterValue": "https://api-int.${CLUSTER_NAME}.${BASE_DOMAIN}:22623/config/master" 
  },
  {
    "ParameterKey": "CertificateAuthorities", 
    "ParameterValue": "${CA}" 
  },
  {
    "ParameterKey": "MasterInstanceProfileName", 
    "ParameterValue": "${MASTER_INSTANCE_PROFILE}" 
  },
  {
    "ParameterKey": "MasterInstanceType", 
    "ParameterValue": "m6i.xlarge" 
  },
  {
    "ParameterKey": "AutoRegisterELB", 
    "ParameterValue": "yes" 
  },
  {
    "ParameterKey": "RegisterNlbIpTargetsLambdaArn", 
    "ParameterValue": "${NLB_LAMBDA_ARN}" 
  },
  {
    "ParameterKey": "ExternalApiTargetGroupArn", 
    "ParameterValue": "${EXT_API_TARGETGROUP_ARN}" 
  },
  {
    "ParameterKey": "InternalApiTargetGroupArn", 
    "ParameterValue": "${INT_API_TARGETGROUP_ARN}" 
  },
  {
    "ParameterKey": "InternalServiceTargetGroupArn", 
    "ParameterValue": "${INT_SVC_TARGETGROUP_ARN}" 
  }
]