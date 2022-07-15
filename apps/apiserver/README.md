## apiserver

Based on https://github.com/joshgav/spring-apiserver.git

- `base-k8s` uses ingress and deploys to Kubernetes
- `base-openshift` uses route and BuildConfig and deploys to OpenShift

- `pipeline` is a work in progress to build the image using Tekton in cluster.
- `keycloak` should be used to configure an OAuth client and env vars for use in
the server. It's image must be built from another branch at the moment.