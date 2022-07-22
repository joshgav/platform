#! /usr/bin/env bash

namespace=superheroes
kubectl config set-context --current --namespace ${namespace}

db_name=villains-db
service_name=rest-villains
kubectl delete postgrescluster "${db_name}"
kubectl delete services.serving.knative.dev "${service_name}"
kubectl delete servicebindings "${service_name}-${db_name}"
