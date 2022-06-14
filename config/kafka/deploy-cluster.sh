#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

namespace=kafka

kustomize build ${this_dir}/base | kubectl apply -n ${namespace} -f -
