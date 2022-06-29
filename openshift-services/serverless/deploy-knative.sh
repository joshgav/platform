#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

kustomize build ${this_dir}/knative | kubectl apply -f -
