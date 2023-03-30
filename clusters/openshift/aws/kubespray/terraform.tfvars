# global
aws_cluster_name = "kubespray"

# VPC
aws_vpc_cidr_block       = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20", "10.250.208.0/20"]
aws_cidr_subnets_public  = ["10.250.224.0/20", "10.250.240.0/20"]

# bastion
aws_bastion_num  = 1
aws_bastion_size = "t3.small"

# masters
aws_kube_master_num       = 3
aws_kube_master_size      = "t3a.xlarge"
aws_kube_master_disk_size = 100

# etcd hosts
aws_etcd_num       = 0
aws_etcd_size      = "t3.medium"
aws_etcd_disk_size = 50

# workers
aws_kube_worker_num       = 2
aws_kube_worker_size      = "t3.medium"
aws_kube_worker_disk_size = 100

# load balancer
aws_nlb_api_port    = 6443
k8s_secure_api_port = 6443

default_tags = {
  Env = "devtest"
  Product = "kubernetes"
}

# context is deep in kubespray repo
inventory_file = "../../../../inventory/cluster/hosts.ini"
