#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
source ${root_dir}/lib/requirements.sh
install_operator_sdk

operator_name=scratch-operator

mkdir -p ${this_dir}/${operator_name}
pushd ${this_dir}/${operator_name}

if [[ ! -e PROJECT ]]; then
    operator-sdk init --plugins go/v3 --project-version 3 \
        --domain 'joshgav.com' \
        --owner 'joshgav' \
        --project-name ${operator_name} \
        --repo "github.com/joshgav/${operator_name}"
else
  echo "INFO: using previously initialized project"
fi

operator-sdk create api --force --controller --resource --make \
    --group 'resources' \
    --version v1alpha1 \
    --kind Scratcher

make deploy

kubectl apply -f ${this_dir}/scratcher.yaml
