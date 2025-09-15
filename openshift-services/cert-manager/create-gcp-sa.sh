#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi

export GCP_PROJECT_ID=openenv-cvcgb
export OPENSHIFT_BASE_DOMAIN=gcp.joshgav.com
export CERTMANAGER_NAMESPACE=cert-manager

gcp_sa_name=dns01-solver

sa_exists=false
set +e
gcloud iam service-accounts list | grep ${gcp_sa_name}@${GCP_PROJECT_ID} --quiet
if [[ $? == 0 ]]; then
    echo "INFO: found existing service account"
    sa_exists=true
else
    echo "INFO: no service account found"
fi
set -e

if [[ ${sa_exists} == "false" ]]; then
    echo "INFO: creating new service account"
    gcloud iam service-accounts create dns01-solver \
        --display-name "dns01-solver" \
        --project ${GCP_PROJECT_ID}
fi

gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
   --member serviceAccount:${gcp_sa_name}@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
   --role roles/dns.admin

gcloud iam service-accounts keys create ${this_dir}/key.json \
   --iam-account ${gcp_sa_name}@${GCP_PROJECT_ID}.iam.gserviceaccount.com

export GCP_SERVICEACCOUNT_KEY=$(cat ${this_dir}/key.json)

oc create secret generic clouddns-serviceaccount-secret \
    --namespace ${CERTMANAGER_NAMESPACE} \
    --from-file=${this_dir}/key.json || true
