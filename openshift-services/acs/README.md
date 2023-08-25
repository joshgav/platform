# ACS

- Docs: https://docs.openshift.com/acs

## Deploy

1. Get an API token from <https://central-stackrox.apps.ipi.aws.joshgav.com/main/integrations/authProviders/apitoken>
1. Set API token in environment - use `.env` in this directory.
1. Set `ROX_ENDPOINT` in environment to `host:port` of Central, e.g. `central-stackrox.apps.ipi.aws.joshgav.com:443`
1. On Hub cluster run `deploy-central.sh` to deploy operator and Central resource.
1. (Optional) On Hub cluster run `deploy-securedcluster.sh` to add Hub as a secured cluster.
1. On Hub cluster run `deploy-securedcluster-acm.sh` to add a policy to register every managed cluster.
