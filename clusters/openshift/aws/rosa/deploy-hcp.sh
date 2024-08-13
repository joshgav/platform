#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

echo "INFO: creating cluster named ${CLUSTER_NAME} in region ${AWS_REGION}"

account_roles_prefix="ManagedOpenShift"
operator_roles_prefix=${CLUSTER_NAME}
# default instance type is m5.xlarge
# instance_type=m6i.4xlarge
instance_type=m5.xlarge

echo "INFO: Verify login to AWS"
aws sts get-caller-identity &> /dev/null
if [[ $? != 0 ]]; then
    echo "ERROR: invalid AWS credentials; could not call AWS APIs"
    exit 2
fi

# get a token at https://console.redhat.com/openshift/token/rosa/
echo "INFO: Verifying login to RH OCM"
rosa login --token="${REDHAT_ACCOUNT_TOKEN}" &> /dev/null
if [[ $? != 0 ]]; then
    echo "ERROR: invalid Red Hat credentials; could not call RH OCM APIs"
    exit 2
fi

echo "INFO: deploy VPC via Terraform"
${this_dir}/deploy-vpc-tf.sh ${CLUSTER_NAME} ${AWS_REGION}
SUBNET_IDS=$(terraform output -raw -state=${this_dir}/tf-vpc/terraform.tfstate cluster-subnets-string)
echo "INFO: Subnet IDs: ${SUBNET_IDS}"

## if role already exists will emit warning and continue
echo "INFO: create ocm-role"
rosa create ocm-role --admin --mode=auto --prefix="${account_roles_prefix}" --yes

## if role already exists will emit warning and continue
echo "INFO: create user-role"
rosa create user-role --mode=auto --prefix="${account_roles_prefix}" --yes

echo "INFO: create account-roles"
rosa create account-roles --hosted-cp --force-policy-creation --prefix "${account_roles_prefix}" --yes --mode=auto --interactive=false

## creates or uses one global OIDC config for the AWS account
echo "INFO: create or get oidc-config"
oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
if [[ "null" == "${oidc_config_id}" ]]; then
    echo "INFO: oidc-config not found, creating one"
    rosa create oidc-config --yes --mode=auto
    oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
fi
echo "INFO: using oidc-config with ID ${oidc_config_id}"

echo "INFO: gather account role ARNs"
installer_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${account_roles_prefix}-HCP-ROSA-Installer-Role\") | .RoleARN")
worker_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${account_roles_prefix}-HCP-ROSA-Worker-Role\") | .RoleARN")
support_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${account_roles_prefix}-HCP-ROSA-Support-Role\") | .RoleARN")
echo -e "INFO: using role ARNs:\n\tinstaller_role_arn ${installer_role_arn}\n\tworker_role_arn ${worker_role_arn}\n\tsupport_role_arn ${support_role_arn}"

echo "INFO: apply operator-roles"
rosa create operator-roles --hosted-cp --mode=auto --yes \
    --force-policy-creation \
    --installer-role-arn "${installer_role_arn}" \
    --oidc-config-id ${oidc_config_id} \
    --prefix ${operator_roles_prefix}

billing_account=$(aws sts get-caller-identity --output json | jq -r '.Account')

echo "INFO: create cluster"
rosa create cluster --cluster-name "${CLUSTER_NAME}" --mode=auto --yes --watch \
    --sts --hosted-cp --region ${AWS_REGION} \
    --role-arn ${installer_role_arn} \
    --worker-iam-role ${worker_role_arn} \
    --support-role-arn ${support_role_arn} \
    --operator-roles-prefix ${operator_roles_prefix} \
    --billing-account ${billing_account} \
    --oidc-config-id ${oidc_config_id} \
    --compute-machine-type "${instance_type}" \
    --subnet-ids "${SUBNET_IDS}" \
    --enable-autoscaling --min-replicas 3 --max-replicas 36
