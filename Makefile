export root_dir = $(realpath .)
export BASH_ENV := $(shell ${root_dir}/.env)
SHELL := bash

# cluster:

kafka-operator:
	${root_dir}/config/kafka/deploy-operator.sh

kafka-cluster: kafka-operator
	${root_dir}/config/kafka/deploy-cluster.sh

cert-manager:
	${root_dir}/config/cert-manager/deploy-libvirt.sh

argocd:
	${root_dir}/config/argocd/deploy.sh