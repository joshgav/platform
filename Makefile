export root_dir = $(realpath .)
include ${root_dir}/.env

# cluster:

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

apiserver: # postgres
	${root_dir}/services/apiserver/deploy.sh

postgres-argo:
	${root_dir}/services/postgres/deploy-argo.sh

apiserver-argo: postgres-argo
	${root_dir}/services/apiserver/deploy-argo.sh