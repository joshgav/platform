## Quarkus Superheroes Demo

This app is based on [Quarkus
Superheroes](https://github.com/quarkusio/quarkus-super-heroes) but uses
operator-managed backing services such as databases.

## Develop

1. Clone the upstream repo: `git clone https://github.com/quarkusio/quarkus-super-heroes superheroes`
1. Open a dev session in a separate terminal session for any or all of the components:

```bash
workdir=./superheroes
registry_user=joshgav

# session 1
cd ${workdir}/rest-villains && quarkus dev

# session 2
cd ${workdir}/rest-heroes && quarkus dev

# session 3
cd ${workdir}/rest-fights && quarkus dev

# session 4
cd ${workdir}/event-statistics && quarkus dev

# session 5
cd superheroes/ui-super-heroes && docker build -t quay.io/${registry_user}/ui-super-heroes:latest .
docker run -p 8080:8080 -e API_BASE_URL=http://localhost:8082 quay.io/${registry_user}/ui-super-heroes:latest

# session 6
# open ui-super-heroes app
xdg-open http://localhost:8080/ &
# open rest-heroes app
xdg-open http://localhost:8083/ &
# open rest-villains app
xdg-open http://localhost:8084/ &
# open event-statistics app
xdg-open http://localhost:8085/ &
```

## Deploy

To deploy to a Kubernetes cluster from a logged in context:

1. All custom resources and operators must be installed (see [Requirements](#requirements))
1. Required singleton instances must be online (see [Requirements](#requirements))
1. Run `./deploy.sh` to deploy all components, or deploy individual components
   with `./deploy.sh [ villains | heroes | fights | ui | statistics ]`.

### Requirements

The cluster must offer the following resource groups. They may be installed via operators.

- postgres-operator.crunchydata.com/v1beta1
- registry.apicur.io/v1
- kafka.strimzi.io/v1beta2
- mongodbcommunity.mongodb.com/v1
- serving.knative.dev/v1
- opentelemetry.io/v1alpha1

It also requires existing singleton instances of the following, specified as
service endpoints. You can override default URLs by setting the env vars
indicated; also see `./deploy/.env`. The linked *Operator dir*s contain
deployment instructions for these types and instances.

Service   | Env var   | Default   | Operator dir
----------|-----------|-----------|-------------
Apicurio registry | `apicurio_base_url` | http://apicurio.apicurio:8080 | [Operator dir](../../openshift-services/apicurio/)
Kafka broker | `kafka_boostrap_servers` | PLAINTEXT://cluster-main-kafka-bootstrap.kafka-cluster:9094 | [Operator dir](../../openshift-services/kafka/)
OpenTelemetry collector | `opentelemetry_collector_endpoint` | http://otel-collector-collector.opentelemetry:4317 | [Operator dir](../../openshift-services/opentelemetry/)

`container_image_group_name` should be set to your username in
[quay.io](https://quay.io/). You must be logged in with rights to push the
resultant tags.

## Notes

You must grant the service account for service-binding-operator rights to manage
knative services.

The `mongodbcommunity-view` role is added as part of the operator deployment in
[this repo](../../openshift-services/mongodb/).

```bash
sa='openshift-operators:service-binding-operator'

# knative services - view and edit
oc create clusterrolebinding sbo-knative \
    --clusterrole=knative-serving-admin \
    --serviceaccount "${sa}"

# mongodbcommunity - view
oc create clusterrolebinding sbo-mongodb \
    --clusterrole=mongodbcommunity-view \
    --serviceaccount "${sa}"
```

### Podman

Quarkus tests depend on TestContainers, which in turn depends on the Docker
daemon and socket. If using podman on Linux, follow these steps to use it
instead.

See <https://quarkus.io/blog/quarkus-devservices-testcontainers-podman/>.

```bash
sudo dnf install podman podman-docker
systemctl --user enable podman.socket --now
export DOCKER_HOST=unix:///run/user/${UID}/podman/podman.sock
export TESTCONTAINERS_RYUK_DISABLED=true
```
