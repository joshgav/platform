#! /usr/bin/env -S bash -e

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

metallb_version=v0.13.12

kubectl get configmap kube-proxy -n kube-system -o yaml | \
    sed -e "s/strictARP: false/strictARP: true/" | \
        kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/config/manifests/metallb-native.yaml
kubectl apply -f ${this_dir}/base/ipaddresspool.yaml
