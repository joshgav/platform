## Quarkus Superheroes Demo

This app is based on [Quarkus
Superheroes](https://github.com/quarkusio/quarkus-super-heroes) but uses
operator-managed backing services such as databases.

### Tests

Quarkus tests depend on TestContainers, which in turn depends on the Docker
daemon and socket. If using podman on Linux, follow these steps to use it
instead.

```bash
sudo dnf install podman podman-docker
systemctl --user enable podman.socket --now
export DOCKER_HOST=unix:///run/user/${UID}/podman/podman.sock
export TESTCONTAINERS_RYUK_DISABLED=true
```

See <https://quarkus.io/blog/quarkus-devservices-testcontainers-podman/>.

### Image build

The Superheroes app uses Quarkus' Docker builder and pushes to `quay.io` by
default. To change to your user name in Quay, set
`quarkus.container-image.group=${group_name}`. You can pass this as the first
parameter to the `deploy.sh` script, i.e., `deploy.sh joshgav`.

- https://quarkus.io/guides/container-image

### Service Binding

The deploy script adds the `quarkus-kubernetes-service-binding` extension and
replaces upstream's static DB configuration with a CrunchyData-managed DBMS.
Paremeters specifying the database to bind to are added as `-D` values in the
deploy.sh script.

More on service binding:

- https://quarkus.io/guides/deploying-to-kubernetes
- https://github.com/redhat-developer/service-binding-operator
- https://developers.redhat.com/articles/2021/12/22/how-use-quarkus-service-binding-operator

### Use

Run locally with dev mode:

```bash
./mvnw quarkus:dev

# or with Quarkus CLI
quarkus dev
```

### Deploy

Deploy to Kubernetes via build extensions.

- https://quarkus.io/guides/deploying-to-kubernetes
- https://github.com/dekorateio/dekorate/

```bash
## Knative, build local
./mvnw clean package \
    -Dquarkus.profile=knative-17 \
    -Dquarkus.container-image.group=joshgav \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests

## Knative, build with OpenShift BuildConfig
./mvnw clean package \
    -Dquarkus.profile=knative-openshift-17 \
    -Dquarkus.kubernetes.deploy=true \
    -DskipTests
```

### Troubleshooting

Grant SBO service account rights to manage knative services.

```bash
sa='redhat-dbaas-operator:service-binding-operator'
oc create clusterrolebinding sbo-knative \
    --clusterrole=knative-serving-admin \
    --serviceaccount "${sa}"
```
