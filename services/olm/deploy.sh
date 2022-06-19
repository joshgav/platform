#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/requirements.sh
install_operator_sdk

operator-sdk olm status 2> /dev/null
if [[ $? == 1 ]]; then
    operator-sdk olm install --verbose
fi

echo "INFO: operator-sdk olm status"
operator-sdk olm status
