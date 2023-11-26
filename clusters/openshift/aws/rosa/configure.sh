#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source ${this_dir}/init.sh

rosa create idp --cluster ${cluster_name} --type google \
    --name Gmail \
    --mapping-method lookup \
    --client-id "${GOOGLE_SIGNIN_CLIENT_ID}" \
    --client-secret "${GOOGLE_SIGNIN_CLIENT_SECRET}"

rosa create idp --cluster ${cluster_name} --type google \
    --name Google \
    --mapping-method claim \
    --client-id "${GOOGLE_SIGNIN_CLIENT_ID}" \
    --client-secret "${GOOGLE_SIGNIN_CLIENT_SECRET}" \
    --hosted-domain redhat.com

# rosa delete idp --cluster ${cluster_name} cluster-admin --yes

if [[ -n "${GOOGLE_IDENTITY_NUMBER}" ]]; then
    # rosa grant user cluster-admin --user=${GOOGLE_IDENTITY_NAME} --cluster=${cluster_name}
    # rosa grant user cluster-admin --user=jgavant@redhat.com --cluster=${cluster_name}

    oc create identity Gmail:${GOOGLE_IDENTITY_NUMBER}
    oc create user ${GOOGLE_IDENTITY_NAME} --full-name="${GOOGLE_IDENTITY_FULLNAME}"
    oc create useridentitymapping Gmail:${GOOGLE_IDENTITY_NUMBER} ${GOOGLE_IDENTITY_NAME}
    oc adm policy add-cluster-role-to-user cluster-admin ${GOOGLE_IDENTITY_NAME}
fi

# extra machine pool
if [[ -n "${APPLY_MACHINE_POOL}" ]]; then
    max_replicas=20
    instance_type=m6i.4xlarge
    az=use2-az1
    rosa create machinepool --cluster ${cluster_name} \
        --name ${az}-pool \
        --enable-autoscaling \
        --instance-type ${instance_type} \
        --max-replicas ${max_replicas} \
        --min-replicas 2
fi
