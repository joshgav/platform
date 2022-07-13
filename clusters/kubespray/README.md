# Cluster: Kubespray

1. Run `deploy-aws-tf.sh` to deploy a standard AWS base env.
1. Apply fixes to inventory and vars files (see below).
1. Run `deploy-cluster.sh` to install the cluster.

## Fixes

These are required for v1.23.7. v1.23.8 does not yet have a kubeadm release.

- Append `ansible_user=ec2-user` to all the hosts in `inventory/cluster/hosts.ini`.
- Set `kube_version` or `kubeadm_version` to valid versions in `clusters/kubespray/inventory/cluster/group_vars/k8s_cluster/k8s-cluster.yml`

These are required for v1.24.1. v1.24.2 does not yet have a kubeadm release.

- In file `/etc/containerd/config.toml` set `SystemdCgroup = true`. Initial setting is `systemdCgroup = true`.
- In file `/etc/kubernetes/kubelet.env` comment out `--network-config` and other CNI flags removed in v1.24.
- In file `/etc/kubernetes/manifests/kube-apiserver.yaml` remove `--insecure-port` which was removed in v1.24.

## R&D

Mount inventory and SSH key into container with prerequisites etc.

```bash
podman run --rm -it \
    --mount type=bind,source=clusters/kubespray/inventory/cluster,dst=/inventory,relabel=shared \
    --mount type=bind,source=.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
        quay.io/kubespray/kubespray:v2.19.0 \
            bash
```
