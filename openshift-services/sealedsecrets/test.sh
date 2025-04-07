#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi

kubeseal --controller-name sealed-secrets --controller-namespace sealed-secrets \
    --format yaml \
    --secret-file ${this_dir}/test/test-secret.yaml \
    --sealed-secret-file ${this_dir}/test/test-sealed-secret.yaml

kubectl apply -f ${this_dir}/test/test-sealed-secret.yaml
