#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
source ${root_dir}/lib/requirements.sh
install_operator_sdk

operator_name=scratch-operator

mkdir -p ${this_dir}/${operator_name}
pushd ${this_dir}/${operator_name}

operator-sdk init --plugins go/v3 --project-version 3 \
    --domain 'joshgav.com' \
    --owner 'joshgav' \
    --project-name ${operator_name} \
    --repo "github.com/joshgav/${operator_name}"

operator-sdk create api --force --group 'resources' --version v1alpha1 --kind Scratcher \
    --controller --resource --make

make deploy

kubectl apply -f ${this_dir}/scratcher.yaml
