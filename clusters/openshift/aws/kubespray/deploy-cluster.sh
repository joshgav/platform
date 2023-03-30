#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

d=podman
v=v2.19.0
## kubeadm download fails for v1.23.8+
## bugs in kubeadm for v1.24+
## so stick with v1.23.7 for now
k8s_version=v1.23.7
ansible_user=ec2-user

${d} pull quay.io/kubespray/kubespray:${v}

${d} run --rm -it \
    --mount type=bind,source=${this_dir}/inventory/cluster,dst=/inventory,relabel=shared \
    --mount type=bind,source=${root_dir}/.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
        quay.io/kubespray/kubespray:${v} \
            ansible-playbook cluster.yml \
                -i /inventory/hosts.ini \
                --private-key /root/.ssh/id_rsa \
                --become --become-user=root \
                -e "kube_version=${k8s_version}" \
                -e "ansible_user=${ansible_user}" \
                -e "kubeconfig_localhost=true"

lb_hostname=$(aws elbv2 describe-load-balancers --output json | jq -r '.LoadBalancers[0].DNSName')
echo "INFO: apiserver URL: https://${lb_hostname}:6443/"
