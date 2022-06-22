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
    operator-sdk create api --force --controller --resource --make \
        --group 'resources' \
        --version v1alpha1 \
        --kind Scratcher
else
    echo "INFO: using previously initialized project"
fi

export IMAGE_TAG_BASE=quay.io/joshgav/scratch-operator
export IMG=${IMAGE_TAG_BASE}:latest
export VERSION=latest
make docker-build
make docker-push

# simple log method to add to `Reconcile()`:
#    log := log.FromContext(ctx)
#    log.Info("Reconciling resource")

make deploy

kubectl apply -f ${this_dir}/scratcher.yaml
