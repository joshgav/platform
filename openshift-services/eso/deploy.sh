#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

${this_dir}/deploy-operator.sh

export AWS_REGION=us-east-2
echo "INFO: creating AWSSM secret (may already exist)"
aws secretsmanager create-secret \
    --name aws-secret01 \
    --secret-string '{ "test-key-01": "test-value-01", "test-key": "test-value" }'

echo "INFO: install ESO operands"
apply_kustomize_dir ${this_dir}/operand
