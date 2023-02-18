## CloudNative-PG for OpenShift

Install [EDB Postgres](https://artifacthub.io/packages/olm/community-operators/cloud-native-postgresql]), which is based on:
- [cloudnative-pg.io](https://cloudnative-pg.io/)
- [github.com/cloudnative-pg/cloudnative-pg](https://github.com/cloudnative-pg/cloudnative-pg)

## Use

1. Clone this repo and enter this directory: `git clone https://github.com/joshgav/devenv.git && cd devenv/openshift-services/postgres`
1. Run `./deploy-operator.sh`.
1. Create and manage resources from group [`postgresql.k8s.enterprisedb.io/v1`](https://github.com/cloudnative-pg/cloudnative-pg/tree/main/api/v1)
   like [`clusters`](https://github.com/cloudnative-pg/cloudnative-pg/blob/main/api/v1/cluster_types.go#L121)
   - See [the Backstage app](../../apps/backstage/base/pgdb.yaml) for an example.
