#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/olm.sh
source ${root_dir}/lib/yaml.sh

registry=${1:-quay.io/joshgav}

# must specify registry in command line, see https://github.com/knative-sandbox/kn-plugin-func/issues/941#issuecomment-1098624971
pushd ${this_dir}/eventsender
kn func deploy --registry "${registry}" --push --verbose \
    --image "${registry}/eventsender:latest"
popd

pushd ${this_dir}/eventreceiver
kn func deploy --registry "${registry}" --push --verbose \
    --image "${registry}/eventreceiver:latest"
popd

apply_kustomize_dir ${this_dir}/deployment

(
    cd ${this_dir}/eventsender
    kn func invoke
)