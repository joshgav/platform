export root_dir = $(realpath .)
include ${root_dir}/.env

openshift-aws-ipi:
	${root_dir}/clusters/openshift-aws-ipi/deploy.sh

openshift-cert-manager:
	${root_dir}/openshift-services/cert-manager/deploy.sh

openshift-sso-operator:
	${root_dir}/openshift-services/rhsso/deploy-operator.sh

openshift-sso-realm:
	${root_dir}/openshift-services/rhsso/deploy.sh

openshift-serverless-operator:
	${root_dir}/openshift-services/serverless/deploy-operator.sh

openshift-serverless-knative:
	${root_dir}/openshift-services/serverless/deploy-knative.sh

libvirt-pvs:
	cd ${root_dir}/infrastructure/libvirt && $(MAKE) pvs

destroy-libvirt-pvs:
	cd ${root_dir}/infrastructure/libvirt && $(MAKE) destroy-pvs

kafka-operator:
	${root_dir}/services/kafka/deploy-operator.sh

kafka-cluster: kafka-operator
	${root_dir}/services/kafka/deploy-cluster.sh

cert-manager:
	${root_dir}/services/cert-manager/deploy.sh

dashboard:
	${root_dir}/services/dashboard/deploy.sh

olm:
	${root_dir}/services/olm/deploy.sh

argocd:
	${root_dir}/services/argocd/deploy.sh

crossplane:
	${root_dir}/services/crossplane/deploy.sh

postgres:
	${root_dir}/services/postgres/deploy.sh

keycloak:
	${root_dir}/services/keycloak/deploy.sh

tekton:
	${root_dir}/services/tekton/deploy.sh

postgres-argo:
	${root_dir}/services/postgres/deploy-argo.sh

apiserver: # postgres
	${root_dir}/apps/apiserver/deploy.sh

apiserver-argo: postgres-argo
	${root_dir}/apps/apiserver/deploy-argo.sh