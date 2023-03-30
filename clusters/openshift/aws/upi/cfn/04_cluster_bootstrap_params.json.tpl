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
    "ParameterKey": "AllowedBootstrapSshCidr", 
    "ParameterValue": "0.0.0.0/0" 
  },
  {
    "ParameterKey": "PublicSubnet", 
    "ParameterValue": "${PUBLIC_SUBNET_01}" 
  },
  {
    "ParameterKey": "MasterSecurityGroupId", 
    "ParameterValue": "${MASTER_SG_ID}" 
  },
  {
    "ParameterKey": "VpcId", 
    "ParameterValue": "${VPC_ID}" 
  },
  {
    "ParameterKey": "BootstrapIgnitionLocation", 
    "ParameterValue": "s3://${BOOTSTRAP_IGNITION_BUCKET_NAME}/bootstrap.ign" 
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
