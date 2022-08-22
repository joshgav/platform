# Keycloak

1. Deploy operator, service and realm with `deploy.sh`. Default namespace is `keycloak`, optionally specify target namespace as parameter.

To enable federation with Windows Active Directory via LDAP, set LDAP parameters in `./msad/.env` and use `msad` kustomize dir instead of `local`.

Get admin username and password:

```bash
oc get secret -n keycloak credential-main -o json | jq -r '.data.ADMIN_USERNAME | @base64d'
oc get secret -n keycloak credential-main -o json | jq -r '.data.ADMIN_PASSWORD | @base64d'
```

Get route:

```bash
oc get route -n keycloak keycloak -o json | jq -r '.status.ingress[0].host'
```
