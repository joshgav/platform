#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/install.sh

install_operator_sdk

operator_name=resource-operator

mkdir -p ${this_dir}/${operator_name}
pushd ${this_dir}/${operator_name}

if [[ ! -e PROJECT ]]; then
    operator-sdk init --plugins go/v3 --project-version 3 \
        --domain 'joshgav.com' \
        --owner 'joshgav' \
        --project-name ${operator_name} \
        --repo "github.com/joshgav/${operator_name}"
    operator-sdk create api --force --controller --resource --make \
        --group 'resources' \
        --version v1alpha1 \
        --kind ExampleResource
else
    echo "INFO: using previously initialized project"
fi

## add code from ./reconcile.go.md

export IMAGE_TAG_BASE=quay.io/joshgav/${operator_name}
export IMG=${IMAGE_TAG_BASE}:latest
export VERSION=latest
make docker-build
make docker-push

popd
