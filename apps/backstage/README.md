## Backstage developer portal on OpenShift

Deploy a Backstage portal instance in an OpenShift cluster.

Edit these ConfigMaps to dynamically reconfigure the portal. NOTE: **delete the
current pod** so the modified configMap is loaded.

- bs1-backstage-app-config-base
- bs1-backstage-app-config-cluster

For example, add a URL-based location, or delete one, then delete (that is,
restart) the pod.

### Dependencies

- [EDB Postgres][] - [openshift-services/postgres][]

## Build and deploy (first time)

1. Install dependencies in cluster.
1. Clone repo and change dir: `git clone https://github.com/joshgav/devenv.git && cd devenv/apps/backstage`
1. Set env var `QUAY_USER_NAME` in `.env` file or via `export`
1. Run `npx @backstage/create-app@latest --path bs1`
1. Run `REBUILD_IMAGE=1 ./deploy.sh`

- Visit your instance at <https://bs1-backstage-backstage.${openshift_ingress_domain}>,
  where `openshift_ingress_domain` is found via `oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain`
- The resolved URL is echoed at the end of `deploy.sh` (which can be run anytime)

## Iterate

- Modify Backstage instance in `bs1` directory
- Reconfigure and deploy with `deploy.sh` (it's idempotent)
- Rebuild, reconfigure and deploy with `REBUILD_IMAGE=1 ./deploy.sh`
- Follow logs: `kubectl logs --follow deployment/bs1-backstage`
- Troubleshoot the image: `kubectl run -it --image quay.io/${QUAY_USER_NAME}/bs1-backstage:latest --rm bs-test -- bash`

## Delete

Delete the namespace `backstage` (`kubectl delete namespace backstage`) and start over.

## Notes

- On the first deployment the Backstage pod is ready before the database cluster
  so it crashloops a few times and then stabilizes.
- app-configs are applied in order: `base`, then `cluster`
- Remember to make the image repo at `quay.io/${quay_user_name}/bs1-backstage`
  public; quay.io marks repos private by default.
- The chart uses app-config files specified in this directory _only_ - _not_ use
  the app-config files in the `bs1` subdirectory - even though they are embedded
  in the image.
- If you have OpenTelemetry in your cluster uncomment the
  `base/instrumentation.yaml` file to add OpenTelemetry injection to the namespace
  and the Backstage deployment.

[EDB Postgres]: https://artifacthub.io/packages/olm/community-operators/cloud-native-postgresql
[openshift-services/postgres]: ../../openshift-services/postgres