## OpenShift Builds

### Walkthrough

All Builds and BuildRuns were created in namespace `openshift-builds`. To run in
another namespace be sure to create and update that namespace's service accounts
in the same way.

Builder pod container security contexts request `runAsUser: 0`, capability
`SETFCAP` and run under serviceaccount `default`. Thus
this serviceaccount must allowed to use a privileged SCC:

```bash
oc adm policy add-scc-to-user privileged -z default
```

Could not use internal registry directly due to unrecognized x509 certificate
(signed by openshift-service-signing-signer). Exposed internal registry via
default route with `spec.defaultRoute: true` in
configs.imageregistry.operator.openshift.io and wrote to that address instead.

Create a push secret with enough rights to create a new image stream:

```bash
sa_name=registry-client
sa_namespace=openshift-builds
registry_server=default-route-openshift-image-registry.apps.ipi.aws.joshgav.com

oc create serviceaccount -n ${sa_namespace} ${sa_name}
oc adm policy add-cluster-role-to-user system:image-pusher --serviceaccount ${sa_name} -n ${sa_namespace}
oc adm policy add-cluster-role-to-user system:image-builder --serviceaccount ${sa_name} -n ${sa_namespace}

## to create a long-lived serviceaccount token for the push secret:
oc apply -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${sa_name}
  namespace: ${sa_namespace}
  annotations:
    kubernetes.io/service-account.name: ${sa_name}
EOF

sa_token=$(oc get secrets -n ${sa_namespace} ${sa_name} -ojson | jq -r '.data["token"] | @base64d')

oc create secret docker-registry internal-push-secret -n openshift-builds \
    --docker-username ${sa_name} \
    --docker-password ${sa_token} \
    --docker-server ${registry_server} \
    --docker-email user@openshift.com

oc secrets link -n ${sa_namespace} default internal-push-secret --for=pull,mount
```

Here's the Build:

```yaml
apiVersion: shipwright.io/v1beta1
kind: Build
metadata:
  name: sample-go-app
  namespace: openshift-builds
spec:
  output:
    image: default-route-openshift-image-registry.apps.ipi.aws.joshgav.com/openshift-builds/sample-go-app
    pushSecret: internal-push-secret
  paramValues:
    - name: dockerfile
      value: Dockerfile
  source:
    contextDir: docker-build
    git:
      url: 'https://github.com/shipwright-io/sample-go'
    type: Git
  strategy:
    kind: ClusterBuildStrategy
    name: buildah
```

### Todo

- Verify that `service` and `serviceMonitor` for build-controller metrics work as expected
- Try an S2I build

### Resources

- https://docs.openshift.com/builds/
- https://github.com/shipwright-io
- https://github.com/redhat-openshift-builds