# Keycloak / RHSSO

- To deploy an instance of Keycloak and a single realm to manage IAM for the cluster, run `./deploy-cluster-iam.sh`.
- To deploy an instance of Keycloak and a single realm to manage IAM for an app, run `./deploy-app-iam.sh <app_name>`.

## Info

- To enable federation with Windows Active Directory via LDAP, set LDAP parameters in `./msad/.env` and use `msad` kustomize dir instead of `local`.
- `admin` password is stored in `credential-<realm_name>`.
- Route is stored in `keycloak` route.
