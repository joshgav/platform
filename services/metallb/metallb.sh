#! /usr/bin/env -S bash -e

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

kubectl get configmap kube-proxy -n kube-system -o yaml | \
    sed -e "s/strictARP: false/strictARP: true/" | \
        kubectl apply -f - -n kube-system

metallb_version=v0.12.1

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/manifests/metallb.yaml

kubectl apply -f ${this_dir}/lb-configmap.yaml
