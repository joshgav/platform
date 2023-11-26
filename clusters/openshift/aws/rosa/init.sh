#! /usr/bin/env bash

export this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
export root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

export cluster_name=${1:-${CLUSTER_NAME:-rosa1}}
export AWS_REGION=${2:-${AWS_REGION:-us-east-2}}
# default instance type is m5.xlarge
export instance_type=m6i.4xlarge

echo "INFO: creating cluster named ${cluster_name} in region ${AWS_REGION}"

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
rosa whoami &> /dev/null

echo "INFO: check for existing cluster named ${cluster_name}"
export cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")
if [[ -n ${cluster_json} ]]; then
    echo "INFO: found existing cluster named ${cluster_name}"
else
    echo "INFO: cluster ${cluster_name} not found"
fi
