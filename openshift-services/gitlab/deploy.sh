#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

namespace=gitlab-system
cert_issuer_email=${EMAIL:-test@example.com}
openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)
ensure_namespace ${namespace} true
oc adm policy add-scc-to-group privileged system:serviceaccounts:${namespace}
oc apply -f ${this_dir}/resources

ensure_helm_repo gitlab https://charts.gitlab.io/
helm upgrade --install gitlab gitlab/gitlab \
    --set global.hosts.domain=${openshift_ingress_domain} \
    --set certmanager.install=false \
    --set certmanager-issuer.email=${cert_issuer_email}
