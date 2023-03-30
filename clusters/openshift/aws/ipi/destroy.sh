#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

workdir=${this_dir}/_workdir
if [[ ! -e ${workdir} ]]; then
    echo "ERROR: cannot destroy cluster without workdir"
    exit 2
fi

openshift-install destroy cluster --dir ${workdir} --log-level debug
