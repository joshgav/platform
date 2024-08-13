#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

function create_cluster () {
    local cluster_name=${1}

    echo "INFO: create ocm-role --admin"
    rosa create ocm-role --admin --yes --mode=auto

    echo "INFO: create user-role"
    rosa create user-role        --yes --mode=auto

    echo "INFO: create account-roles"
    rosa create account-roles --prefix ${cluster_name} --yes --mode=auto

    echo "INFO: gathering account role ARNs"
    installer_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-Installer-Role\") | .RoleARN")
    controlplane_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-ControlPlane-Role\") | .RoleARN")
    worker_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-Worker-Role\") | .RoleARN")
    support_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-Support-Role\") | .RoleARN")
    echo -e "INFO: using installer_role_arn ${installer_role_arn}\ncontrolplane_role_arn ${controlplane_role_arn}\nworker_role_arn ${worker_role_arn}\nsupport_role_arn ${support_role_arn}"

    echo "INFO: create cluster"
    rosa create cluster --sts --cluster-name "${cluster_name}" --mode=auto --yes --watch \
        --role-arn ${installer_role_arn} \
        --controlplane-iam-role ${controlplane_role_arn} \
        --worker-iam-role ${worker_role_arn} \
        --support-role-arn ${support_role_arn} \
        --create-admin-user
}

echo "INFO: creating cluster named ${CLUSTER_NAME} in region ${AWS_REGION}"

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

export cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${CLUSTER_NAME}\") )")
if [[ -n ${cluster_json} ]]; then
    echo "WARNING: found existing cluster named ${CLUSTER_NAME}, skipping 'create' commands"
else
    echo "INFO: cluster not found, creating now"
    create_cluster "${CLUSTER_NAME}"
    echo "INFO: updating cluster info"
    export cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${CLUSTER_NAME}\") )")
    echo -e "INFO: updated cluster info:\n$(echo ${cluster_json} | jq)"
fi
