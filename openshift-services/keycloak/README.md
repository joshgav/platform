# Keycloak / RHSSO

- To use GitHub auth with the cluster Keycloak you must [create a GitHub OAuth App](https://github.com/settings/applications/new) and set GITHUB_OAUTH_CLIENT_{ID,SECRET} accordingly.
    - The Authorization callback URL will be https://keycloak-cluster-iam.${openshift_ingress_domain}/auth/realms/default/broker/github/endpoint
      where `openshift_ingress_domain` is `oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain`.

- To deploy an instance of Keycloak and a single realm to manage IAM for an OpenShift cluster, run `./deploy-cluster-iam.sh`.
- To deploy an instance of Keycloak and a single realm to manage IAM for an app, run `./deploy-app-iam.sh <app_name>`.
- To enable federation with Windows Active Directory via LDAP, set LDAP parameters in `./msad/.env` and use `msad` kustomize dir instead of `local`.

## Tips

- `admin` password for Keycloak will be stored in `credential-<realm_name>`.
- Route is created as `keycloak` route.
