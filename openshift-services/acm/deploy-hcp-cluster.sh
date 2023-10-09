#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export bucket_name=${BUCKET_NAME}
export bucket_region=${BUCKET_REGION}
export cluster_name=${OPENSHIFT_CLUSTER_NAME}
export cluster_namespace=${OPENSHIFT_CLUSTER_NAMESPACE}
export aws_secret_name=${AWS_SECRET_NAME}

ssh_key_path=${root_dir}/.ssh
export SSH_PUBLIC_KEY="$(cat ${ssh_key_path}/id_rsa.pub)"
export SSH_PRIVATE_KEY="$(cat ${ssh_key_path}/id_rsa)"

ensure_namespace ${cluster_namespace}
tempdir=$(mktemp -d)

echo "INFO: create S3 bucket ${bucket_name}"
aws s3api create-bucket --bucket ${bucket_name} \
  --create-bucket-configuration LocationConstraint=${bucket_region} \
  --region ${bucket_region}
aws s3api delete-public-access-block --bucket ${bucket_name}
echo '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${bucket_name}/*"
        }
    ]
}' | envsubst > ${tempdir}/policy.json
aws s3api put-bucket-policy --bucket ${bucket_name} --policy file://${tempdir}/policy.json

echo '[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
' | envsubst > ${tempdir}/credentials

echo "INFO: create secret for accessing AWS API"
oc create secret generic -n ${cluster_namespace} ${aws_secret_name} \
    --from-literal="aws_access_key_id=${AWS_ACCESS_KEY_ID}" \
    --from-literal="aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
    --from-literal="baseDomain=${OPENSHIFT_BASE_DOMAIN}" \
    --from-literal="pullSecret=${OPENSHIFT_PULL_SECRET}" \
    --from-literal="ssh-publickey=${SSH_PUBLIC_KEY}" \
    --from-literal="ssh-privatekey=${SSH_PRIVATE_KEY}"

echo "INFO: create secret for managing OIDC metadata"
oc create secret generic -n ${cluster_namespace} hypershift-operator-oidc-provider-s3-credentials \
    --from-file=credentials=${tempdir}/credentials \
    --from-literal=bucket=${bucket_name} \
    --from-literal=region=${bucket_region}

# echo "INFO: create secret for managing Route53/DNS"
# oc create secret generic -n ${cluster_namespace} hypershift-operator-external-dns-credentials \
#     --from-literal=provider=aws \
#     --from-literal=domain-filter=hcp.${OPENSHIFT_BASE_DOMAIN} \
#     --from-file=credentials=${tempdir}/credentials

hypershift create cluster aws \
    --name ${cluster_name} \
    --namespace ${cluster_namespace} \
    --node-pool-replicas=3 \
    --secret-creds ${aws_secret_name} \
    --region ${bucket_region} \
    --wait

# hypershift destroy cluster aws \
#   --name hcp \
#   --namespace ${cluster_namespace} \
#   --secret-creds ${aws_secret_name}
