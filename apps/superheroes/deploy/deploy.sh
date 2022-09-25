#! /usr/bin/env bash

set -o allexport
this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
app_dir=$(cd ${this_dir}/.. && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

service_name=${1}
profile=${2:-kubernetes-17}

extra_args=''
if [[ "${profile}" =~ ^kubernetes ]]; then
    extra_args='-Dquarkus.kubernetes.deployment-target=kubernetes'
elif [[ "${profile}" =~ ^knative ]]; then
    ## TODO: ensure no service or route is configured
    ## noop
    echo -n ''
fi

${this_dir}/validate-cluster.sh
ensure_namespace ${app_namespace} true

repo_dir=${app_dir}/superheroes
if [[ ! -e "${repo_dir}/pom.xml" ]]; then
    git clone https://github.com/quarkusio/quarkus-super-heroes.git ${repo_dir}
fi

if [[ -z "${service_name}" ]]; then
    ${this_dir}/deploy-villains.sh
    ${this_dir}/deploy-heroes.sh
    ${this_dir}/deploy-fights.sh
    ${this_dir}/deploy-ui.sh
    ${this_dir}/deploy-statistics.sh
else
    ${this_dir}/deploy-${service_name}.sh
fi
