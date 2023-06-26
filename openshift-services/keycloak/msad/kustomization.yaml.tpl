apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${KEYCLOAK_NAMESPACE}
resources:
- keycloak.yaml
- realm.yaml

patches:
  - target:
        name: main
        group: keycloak.org
        version: v1alpha1
        kind: KeycloakRealm
    patch: |
        [{
            "op": "add",
            "path": "/spec/realm/userFederationProviders/0/config/connectionUrl",
            "value": "${LDAP_CONNECTION_URL}"
        },
        {
            "op": "add",
            "path": "/spec/realm/userFederationProviders/0/config/bindDn",
            "value": "${LDAP_BIND_DN}"
        },
        {
            "op": "add",
            "path": "/spec/realm/userFederationProviders/0/config/bindCredential",
            "value": "${LDAP_BIND_SECRET}"
        },
        {
            "op": "add",
            "path": "/spec/realm/userFederationProviders/0/config/usersDn",
            "value": "${LDAP_USERS_DN}"
        },
        {
            "op": "add",
            "path": "/spec/realm/userFederationMappers/0/config/roles.dn",
            "value": "${LDAP_ROLES_DN}"
        }]