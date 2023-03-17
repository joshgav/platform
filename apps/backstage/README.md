## Quickstart Backstage on OpenShift

Deploy a Backstage portal instance in an OpenShift cluster.

After deployment edit configMap `bs1-backstage-app-config` to dynamically
reconfigure the portal; or change it in the file here and run `deploy.sh` to
reconfigure. NOTE: **delete the current pod** so the modified configMap is
loaded.

For example, try uncommenting one of the commented URL locations in the initial
configMap, then deleting the pod, then refreshing Backstage.

### Dependencies

- [EDB Postgres][] - [openshift-services/postgres][]
- Create a Secret named `github-token` with key `GITHUB_TOKEN` with value set to
  a GitHub Token with repo and workflow permissions.

## Build and deploy (first time)

1. Install dependencies in cluster.
1. Clone repo and change dir: `git clone https://github.com/joshgav/devenv.git && cd devenv/apps/backstage`
1. Set env var `QUAY_USER_NAME` in `.env` file or via `export`
1. Run `npx @backstage/create-app@latest --path bs1`
1. Run `REBUILD_IMAGE=1 ./deploy.sh`

- The resolved URL is echoed at the end of `deploy.sh` (which can be run anytime)

## Iterate

- Visit your instance at <https://bs1-backstage-backstage.${openshift_ingress_domain}>,
  where `openshift_ingress_domain` is found via `oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain`

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
- You must use the latest LTS version of Node.js. Jump to it if you use nvm with
  `nvm use --lts --latest`.
- Import Janus templates at <https://bs1-backstage-backstage.apps.ipi.aws.joshgav.com/catalog-import> from <https://github.com/janus-idp/software-templates/blob/main/showcase-templates.yaml>

[EDB Postgres]: https://artifacthub.io/packages/olm/community-operators/cloud-native-postgresql
[openshift-services/postgres]: ../../openshift-services/postgres