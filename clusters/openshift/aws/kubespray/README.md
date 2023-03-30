# Kubernetes with Kubespray

Deploy a "vanilla" upstream Kubernetes cluster using [Kubespray](https://kubespray.io/).

## Deploy cluster

1. Install [AWS CLI](https://aws.amazon.com/cli/) and [set env vars](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) in `.env`.
1. The OS AMI for EC2 is selected in `variables_override.tf`. By default it is
   Alma Linux, which requires you to subscribe to the image at
   <https://aws.amazon.com/marketplace/pp/prodview-mku4y3g4sjrye>.
1. Set values in `terraform.tfvars` for cluster configuration (or stick with defaults).
1. Set values in `inventory/cluster/group_vars` for cluster configuration (or stick with defaults).
1. Run `deploy-infrastructure.sh` to deploy a target environment in AWS using
   Terraform templates from [`kubespray/contrib/terraform/aws`](https://github.com/kubernetes-sigs/kubespray/tree/master/contrib/terraform/aws).
1. Run `deploy-cluster.sh` to install the cluster using Kubespray's Ansible playbook running in a container.

Note that you'll need the `aws.tfstate` file to maintain the cluster; it will be
written to this directory.

To destroy the cluster, destroy the underlying infrastructure by running
`TF_DESTROY=1 deploy-infrastructure.sh`.

## Use cluster

At the end of Kubespray's Ansible playbook a kubeconfig file for authentication
will be written to `inventory/cluster/artifacts/admin.conf`. At first it will
have the internal IP address of an API server, which won't work from outside
AWS; replace it with the DNS name of the network load balancer provisioned by
kubespray, as determined by the following script. Then point your KUBECONFIG env
var there, as follows:

```bash
## set clusters[0].cluster.server to `https://${lb_hostname}:6443/`
export KUBECONFIG=inventory/cluster/artifacts/admin.conf
lb_hostname=$(aws elbv2 describe-load-balancers --output json | jq -r '.LoadBalancers[0].DNSName')
lb_name=https://${lb_hostname}:6443/
## TODO(test): cat "${KUBECONFIG}" | sed "s/(^.*server: ).*$/\1${lb_name}/" > ${KUBECONFIG}
kubectl get pods -A
```

## Test

To experiment with Kubespray you may mount the inventory and SSH key into a
container with a preinstalled environment, then execute the playbook in that
context. For example:

```bash
podman run --rm -it \
    --mount type=bind,source=kubespray/inventory/cluster,dst=/inventory,relabel=shared \
    --mount type=bind,source=.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
        quay.io/kubespray/kubespray:v2.19.0 \
            bash

# when prompted, enter (for example):
ansible-playbook cluster.yml \
    -i /inventory/hosts.ini \
    --private-key /root/.ssh/id_rsa \
    --become --become-user=root \
    -e "kube_version=v1.23.7" \
    -e "ansible_user=ec2-user"
```

## Notes

- Set `kube_version` to a version with a working `kubeadm` release. `kube_version` is set in `inventory/cluster/group_vars/k8s_cluster/k8s-cluster.yml`.
    - To verify availability of kubeadm releases check for e.g.
`https://storage.googleapis.com/kubernetes-release/release/v1.24.1/bin/linux/amd64/kubeadm`.
