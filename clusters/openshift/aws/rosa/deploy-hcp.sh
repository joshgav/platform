#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
cluster_name=${CLUSTER_NAME:-rosa1}

echo "INFO: deploying VPC using Terraform"
${this_dir}/deploy-vpc.sh

pushd ${this_dir}/tf
export SUBNET_IDS=$(terraform output -raw cluster-subnets-string)
popd
echo "INFO: Subnet IDs as deployed by Terraform: ${SUBNET_IDS}"

echo "INFO: Verify login to AWS"
aws sts get-caller-identity
if [[ $? != 0 ]]; then
    echo "ERROR: invalid AWS credentials; could not call AWS APIs"
    exit 2
fi

# https://console.redhat.com/openshift/token/rosa/
echo "INFO: Verify login to RH OCM"
# re `--env` see https://github.com/openshift/rosa/blob/master/pkg/ocm/config.go
# rosa login --env production --token="${REDHAT_ACCOUNT_TOKEN}"
rosa login --env staging --token="${REDHAT_ACCOUNT_TOKEN}"
if [[ $? != 0 ]]; then
    echo "ERROR: invalid Red Hat credentials; could not call RH Console APIs"
    exit 2
fi
rosa whoami

echo "INFO: check for existing cluster named ${cluster_name}"
cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")
if [[ -n ${cluster_json} ]]; then
    echo "WARNING: found existing cluster named ${cluster_name}, exiting"
    exit 3
else
    echo "INFO: cluster not found, creating now"
fi

rosa create account-roles --hosted-cp --force-policy-creation --prefix ManagedOpenShift --yes

oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
if [[ "null" == "${oidc_config_id}" ]]; then
    echo "INFO: oidc-config not found, creating one"
    rosa create oidc-config --yes --mode=auto
    oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
fi
echo "INFO: using oidc-config with ID ${oidc_config_id}"

installer_role=$(rosa list account-roles --output json | jq -r '.[] | select(.RoleType == "Installer")')
installer_role_arn=$(echo "${installer_role}" | jq -r '.RoleARN' | grep HCP)

role_prefix=${cluster_name}
rosa create operator-roles --hosted-cp --mode=auto --yes \
    --force-policy-creation \
    --installer-role-arn "${installer_role_arn}" \
    --oidc-config-id ${oidc_config_id} \
    --prefix ${role_prefix}

rosa create cluster --cluster-name "${cluster_name}" --mode=auto --yes \
    --sts \
    --hosted-cp \
    --operator-roles-prefix ${role_prefix} \
    --subnet-ids "${SUBNET_IDS}" \
    --oidc-config-id ${oidc_config_id}

rosa create admin --cluster "${cluster_name}" --yes

cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
