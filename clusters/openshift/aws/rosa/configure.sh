#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
cluster_name=${CLUSTER_NAME:-rosa1}

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

rosa delete idp --cluster ${cluster_name} htpasswd --yes

if [[ -n "${GOOGLE_IDENTITY_NUMBER}" ]]; then
    oc create identity Gmail:${GOOGLE_IDENTITY_NUMBER}
    oc create user ${GOOGLE_IDENTITY_NAME} --full-name="${GOOGLE_IDENTITY_FULLNAME}"
    oc create useridentitymapping Gmail:${GOOGLE_IDENTITY_NUMBER} ${GOOGLE_IDENTITY_NAME}
    oc adm policy add-cluster-role-to-user cluster-admin ${GOOGLE_IDENTITY_NAME}
fi

# extra machine pool
max_replicas=20
instance_type=m6i.4xlarge
az=use2-az1
rosa create machinepool --cluster ${cluster_name} \
    --name ${az}-pool \
    --enable-autoscaling \
    --instance-type ${instance_type} \
    --max-replicas ${max_replicas} \
    --min-replicas 2
