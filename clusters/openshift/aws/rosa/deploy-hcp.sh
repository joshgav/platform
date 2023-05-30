#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
cluster_name=${CLUSTER_NAME:-rosa1}

echo "INFO: Verify login to AWS"
aws sts get-caller-identity

echo "INFO: Verify login to RH OCM"
# rosa login --token="${REDHAT_ACCOUNT_TOKEN}"
rosa whoami

echo "INFO: check for existing cluster named ${cluster_name}"
cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")
if [[ -n ${cluster_json} ]]; then
    echo "WARNING: found existing cluster named ${cluster_name}, exiting"
    exit 3
else
    echo "INFO: cluster not found, creating now"
fi

# bind RHOCM to current AWS account
rosa create ocm-role --admin --yes --mode=auto
# bind RHOCM user to current AWS account
rosa create user-role        --yes --mode=auto
# create OpenShift-related roles
rosa create account-roles    --yes --mode=auto

rosa create oidc-config --managed --yes --mode=auto
oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')

## TODO: automate getting installer role ARN
installer_role_arn='arn:aws:iam::115308582586:role/ManagedOpenShift-Installer-Role'
operator_roles_prefix=${cluster_name}-abcd
rosa create operator-roles --mode=auto --yes \
    --hosted-cp \
    --installer-role-arn "${installer_role_arn}" \
    --oidc-config-id ${oidc_config_id} \
    --prefix ${operator_roles_prefix}

pushd ${this_dir}/tf
terraform plan -out rosa.plan -var aws_region=${AWS_REGION} -var cluster_name=${cluster_name}
terraform apply rosa.plan
public_subnet_id=$(terraform output -raw cluster-public-subnet)
private_subnet_id=$(terraform output -raw cluster-private-subnet)
popd

rosa create cluster --cluster-name "${cluster_name}" --mode=auto --yes \
    --sts \
    --hosted-cp \
    --operator-roles-prefix ${operator_roles_prefix} \
    --subnet-ids "${public_subnet_id},${private_subnet_id}" \
    --oidc-config-id ${oidc_config_id}

rosa create admin --cluster "${cluster_name}" --yes

cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
