#! /usr/bin/env -S bash -e

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

export kubernetes_version=${1:-v1.24.1}
export config_dir=${2:-${this_dir}/config}

## TODO: extract further
export apiserver_san=api.cluster1.joshgav.com
export host_ip=192.168.126.10

if [[ "0" != "${UID}" ]]; then
    echo "ABORT: must run as root"
    exit
fi

kubelet_manifest_count=$(sudo ls -1 /etc/kubernetes/manifests | wc -l)
if [[ ${kubelet_manifest_count} == 0 ]]; then
    echo "INFO: installing k8s kubeadm cluster"

    echo "INFO: applying patches/fedora36.sh"
    ${this_dir}/patches/fedora36.sh

    echo "INFO: running kubeadm version:"
    kubeadm version
    echo "INFO: k8s version requested: ${kubernetes_version}"

    temp_config_path=$(mktemp)
    cat ${config_dir}/cluster.yaml | envsubst > ${temp_config_path}

    echo "INFO: running kubeadm init with rendered config at ${temp_config_path}"
    kubeadm init --config ${temp_config_path}
fi

if [[ -n "${OVERWRITE_KUBECONFIG}" ]]; then
    mkdir -p ${root_dir}/.kube
    cp -f /etc/kubernetes/admin.conf ${root_dir}/.kube/config
    chown $(id -u):$(id -g) ${root_dir}/.kube/config
    export KUBECONFIG=${root_dir}/.kube/config
else
    chmod -R 0644 /etc/kubernetes/admin.conf
    export KUBECONFIG=/etc/kubernetes/admin.conf
fi

echo "installing calico pod network"
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl apply -f ${this_dir}/config/calico_installation.yaml
