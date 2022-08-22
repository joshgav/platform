#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/install.sh
install_crossplane_cli

namespace=crossplane-system
helm_repo_name=crossplane
helm_repo_url=https://charts.crossplane.io/stable
helm_chart_name=crossplane
crds_version=v1.8.1

kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace ${namespace}

echo "INFO: applying CRDs from version ${crds_version}"
kubectl apply -k https://github.com/crossplane/crossplane/cluster?ref=${crds_version}

helm repo list | grep "^${helm_repo_name}" &> /dev/null || helm repo add "${helm_repo_name}" "${helm_repo_url}"
helm repo update

helm upgrade --install crossplane --namespace ${namespace} ${helm_repo_name}/${helm_chart_name} \
    --values ${this_dir}/crossplane_values.yaml

aws_creds=$(cat <<EOF
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
)

aws ec2 create-default-vpc 1> /dev/null

kubectl get secret -n ${namespace} aws-creds &> /dev/null
if [[ $? != 0 ]]; then
    kubectl create secret generic aws-creds -n ${namespace} --from-literal=key="${aws_creds}"
fi
kubectl get secret -n ${namespace} dbinstance1-password &> /dev/null
if [[ $? != 0 ]]; then
    kubectl create secret generic dbinstance1-password -n ${namespace} --from-literal=password="$(echo ${RANDOM}${RANDOM}${RANDOM})"
fi

kustomize build ${this_dir}/base | kubectl apply -n ${namespace} -f -
