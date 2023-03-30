#! /usr/bin/env bash

## preamble
this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
ssh_key_path=${root_dir}/.ssh
if [[ -e ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${this_dir}/lib/aws.sh

# set up workdir
workdir=${this_dir}/_workdir
if [[ -e ${workdir} && -z "${RESUME}" && -z "${OVERWRITE}" ]]; then
    echo "WARNING: workdir already exists, set OVERWRITE=1 to remove or RESUME=1 to continue"
    exit 2
elif [[ -e ${workdir} && -n "${RESUME}" ]]; then
    echo "INFO: continuing from existing workdir"
elif [[ -e ${workdir} && -n "${OVERWRITE}" ]]; then
    rm -rf ${workdir}
    mkdir -p "${workdir}"
else
    mkdir -p "${workdir}"
fi

## openshift-install create manifests
echo "INFO: create cluster manifests"
if [[ ! -e "${ssh_key_path}/id_rsa" ]]; then
    ssh-keygen -t rsa -b 4096 -C "user@openshift" -f "${ssh_key_path}/id_rsa" -N ''
fi
export SSH_PUBLIC_KEY="$(cat ${ssh_key_path}/id_rsa.pub)"
cat ${this_dir}/install-config.yaml.tpl | envsubst 1> ${workdir}/install-config.yaml
openshift-install create manifests --dir "${workdir}"

## remove installer-provisioned machines
rm -f ${workdir}/openshift/99_openshift-cluster-api_master-machines-*.yaml
rm -f ${workdir}/openshift/99_openshift-cluster-api_worker-machineset-*.yaml

## extract generated infrastructure name
export INFRASTRUCTURE_NAME=$(cat ${workdir}/.openshift_install_state.json | jq -r '."*installconfig.ClusterID".InfraID')

## a hosted zone must be preconfigured for ${BASE_DOMAIN}; get its ID
export ROUTE53_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "${BASE_DOMAIN}." --max-items 1 --output json | \
                    jq -r '.HostedZones[0].Id' | sed 's/\/hostedzone\///')
if [[ -z "${ROUTE53_ZONE_ID}" ]]; then
    echo "ERROR: base domain must be configured in Route53"
    exit 2
fi

## determine RHCOS AMI ID for later in install
export REGIONAL_RHCOS_AMI_ID=$(openshift-install coreos print-stream-json | \
    jq -r ".architectures.x86_64.images.aws.regions[\"${AWS_REGION}\"].image")
ami_name=$(aws ec2 describe-images --image-ids ${REGIONAL_RHCOS_AMI_ID} --output json | jq -r '.Images[0].Name')
echo "INFO: using AMI ID ${REGIONAL_RHCOS_AMI_ID}, name ${ami_name}"

## provision infrastructure
echo "INFO: provision infrastructure"
stages=(
    "01_vpc"
    "02_cluster_infra"
    "03_cluster_security"
    "04_cluster_bootstrap"
    "05_cluster_master_nodes"
    "06_cluster_worker_node"
)

## -----------------
## 01_vpc
##
stack_name=${stages[0]}
echo "INFO: ensure cfn stack \"${stack_name}\""
ensure_stack ${stack_name} "${this_dir}/cfn"
await_stack ${stack_name}

# outputs
stack_short_name=$(echo "${stack_name}" | sed -E 's/^[0-9]{2}_//')
stack_outputs=$(aws cloudformation describe-stacks --stack-name "${stack_short_name}" --output json | jq '.Stacks[0].Outputs')
export VPC_ID=$(get_value_from_outputs "${stack_outputs}" "VpcId")
export PUBLIC_SUBNET_IDS=$(get_value_from_outputs "${stack_outputs}" "PublicSubnetIds")
export PRIVATE_SUBNET_IDS=$(get_value_from_outputs "${stack_outputs}" "PrivateSubnetIds")

## -----------------
## 02_cluster_infra
##
stack_name=${stages[1]}
echo "INFO: ensure cfn stack \"${stack_name}\""
cat "${this_dir}/cfn/${stack_name}_params.json.tpl" | envsubst > "${this_dir}/cfn/${stack_name}_params.json"
ensure_stack ${stack_name} "${this_dir}/cfn"
await_stack ${stack_name}

# outputs
stack_outputs=$(aws cloudformation describe-stacks --stack-name "$(fix_stack_name ${stack_name})" --output json | jq '.Stacks[0].Outputs')
export NLB_LAMBDA_ARN=$(get_value_from_outputs "${stack_outputs}" "RegisterNlbIpTargetsLambda")
export EXT_API_TARGETGROUP_ARN=$(get_value_from_outputs "${stack_outputs}" "ExternalApiTargetGroupArn")
export INT_API_TARGETGROUP_ARN=$(get_value_from_outputs "${stack_outputs}" "InternalApiTargetGroupArn")
export INT_SVC_TARGETGROUP_ARN=$(get_value_from_outputs "${stack_outputs}" "InternalServiceTargetGroupArn")
export ROUTE53_PRIVATE_HOSTEDZONE_ID=$(get_value_from_outputs "${stack_outputs}" "PrivateHostedZoneId")
# ExternalApiLoadBalancerName
# InternalApiLoadBalancerName
# ApiServerDnsName

## -----------------
## 03_cluster_security
##
stack_name=${stages[2]}
echo "INFO: ensure cfn stack \"${stack_name}\""
cat "${this_dir}/cfn/${stack_name}_params.json.tpl" | envsubst > "${this_dir}/cfn/${stack_name}_params.json"
ensure_stack ${stack_name} "${this_dir}/cfn"
await_stack ${stack_name}

# outputs
stack_outputs=$(aws cloudformation describe-stacks --stack-name "$(fix_stack_name ${stack_name})" --output json | jq '.Stacks[0].Outputs')
export MASTER_SG_ID=$(get_value_from_outputs "${stack_outputs}" "MasterSecurityGroupId")
export MASTER_INSTANCE_PROFILE=$(get_value_from_outputs "${stack_outputs}" "MasterInstanceProfile")
export WORKER_SG_ID=$(get_value_from_outputs "${stack_outputs}" "WorkerSecurityGroupId")
export WORKER_INSTANCE_PROFILE=$(get_value_from_outputs "${stack_outputs}" "WorkerInstanceProfile")

## -----------------
## 04_cluster_bootstrap
##
if [[ -e ${workdir}/auth/kubeconfig ]]; then
    ## bootstrap machine is deleted after use, so it may be missing although cluster exists
    echo "INFO: skipping bootstrap stack"
else
    stack_name=${stages[3]}
    echo "INFO: ensure cfn stack \"${stack_name}\""

    # public subnet
    IFS=',' read -a public_subnets <<< ${PUBLIC_SUBNET_IDS}
    export PUBLIC_SUBNET_01="${public_subnets[0]}"

    # create Ignition configs
    # upload bootstrap.ign to bucket named BOOTSTRAP_IGNITION_BUCKET_NAME
    openshift-install create ignition-configs --dir "${workdir}"
    export BOOTSTRAP_IGNITION_BUCKET_NAME=${INFRASTRUCTURE_NAME}-bootstrap
    aws s3 mb s3://${BOOTSTRAP_IGNITION_BUCKET_NAME}
    aws s3 cp ${workdir}/bootstrap.ign s3://${BOOTSTRAP_IGNITION_BUCKET_NAME}/bootstrap.ign 
    cat "${this_dir}/cfn/${stack_name}_params.json.tpl" | envsubst > "${this_dir}/cfn/${stack_name}_params.json"
    ensure_stack ${stack_name} "${this_dir}/cfn"
    await_stack ${stack_name}

    # outputs
    stack_outputs=$(aws cloudformation describe-stacks --stack-name "$(fix_stack_name ${stack_name})" --output json | jq '.Stacks[0].Outputs')
    # BootstrapInstanceId
    # BootstrapPublicIp
    # BootstrapPrivateIp
fi

## -----------------
## 05_cluster_master_nodes
##
stack_name=${stages[4]}
echo "INFO: ensure cfn stack \"${stack_name}\""

## master subnets, CA
IFS=',' read -a private_subnets <<< ${PRIVATE_SUBNET_IDS}
export PRIVATE_SUBNET_01="${private_subnets[0]}"
export CA=$(cat ${workdir}/master.ign | jq -r '.ignition.security.tls.certificateAuthorities[0].source')

cat "${this_dir}/cfn/${stack_name}_params.json.tpl" | envsubst > "${this_dir}/cfn/${stack_name}_params.json"
ensure_stack ${stack_name} "${this_dir}/cfn"
await_stack ${stack_name}

# outputs
# stack_outputs=$(aws cloudformation describe-stacks --stack-name "$(fix_stack_name ${stack_name})" --output json | jq '.Stacks[0].Outputs')
# PrivateIPs

## -----------------
## 06_cluster_worker_node
##
stack_name=${stages[5]}
echo "INFO: ensure cfn stack \"${stack_name}\""
cat "${this_dir}/cfn/${stack_name}_params.json.tpl" | envsubst > "${this_dir}/cfn/${stack_name}_params.json"
ensure_stack ${stack_name} "${this_dir}/cfn"
await_stack ${stack_name}

# outputs
# stack_outputs=$(aws cloudformation describe-stacks --stack-name "$(fix_stack_name ${stack_name})" --output json | jq '.Stacks[0].Outputs')
# PrivateIPs

## ----------------
## Finish
##
openshift-install wait-for bootstrap-complete --dir "${workdir}" --log-level=debug

## run script to approve CSRs in background; it loops and checks for CSRs every 5s
${this_dir}/approve_csrs.sh &
csrs_pid=$!
trap "kill ${csrs_pid}" EXIT

openshift-install --dir ${workdir} wait-for install-complete --log-level=debug
