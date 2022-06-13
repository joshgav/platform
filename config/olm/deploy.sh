#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/requirements.sh
# source ${root_dir}/lib/operators.sh

install_operator_sdk

echo "INFO: installing operator-sdk CLI"
operator-sdk olm status 2> /dev/null
if [[ $? == 1 ]]; then
    operator-sdk olm install --verbose
fi
echo "INFO: operator-sdk olm status"
operator-sdk olm status
