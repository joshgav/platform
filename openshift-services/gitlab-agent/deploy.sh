#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

agent_name=default
namespace=gitlab-agent-${agent_name}

ensure_helm_repo gitlab https://charts.gitlab.io/
ensure_namespace ${namespace} true

helm upgrade --install gitlab-agent-${agent_name} gitlab/gitlab-agent \
    --set config.token=${GITLAB_AGENT_SECRET} \
    --set serviceMonitor.enabled=true \
    --set config.kasAddress=wss://kas.gitlab.com
