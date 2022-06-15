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

crossplane:
	${root_dir}/config/crossplane/deploy.sh

postgres:
	${root_dir}/config/postgres/deploy.sh

dashboard:
	${root_dir}/config/dashboard/deploy.sh

keycloak:
	${root_dir}/config/keycloak/deploy.sh

tekton:
	${root_dir}/config/tekton/deploy.sh

apiserver: # postgres keycloak
	${root_dir}/config/apiserver/deploy.sh