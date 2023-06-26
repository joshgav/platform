apiVersion: keycloak.org/v1alpha1
kind: KeycloakRealm
metadata:
  name: ${cluster_keycloak_realm_name}
  labels:
    keycloak: ${cluster_keycloak_name}
    realm: ${cluster_keycloak_realm_name}
spec:
  instanceSelector:
    matchLabels:
      keycloak: ${cluster_keycloak_name}
  realm:
    id: ${cluster_keycloak_realm_name}
    realm: ${cluster_keycloak_realm_name}
    displayName: ${cluster_keycloak_realm_name}
    enabled: true
    identityProviders:
      - alias: github
        providerId: github
        config:
          clientId: ${GITHUB_OAUTH_CLIENT_ID}
          clientSecret: ${GITHUB_OAUTH_CLIENT_SECRET}
          syncMode: IMPORT
    identityProviderMappers:
      - name: role-github-users
        identityProviderAlias: github
        identityProviderMapper: oidc-hardcoded-role-idp-mapper
        config:
          syncMode: FORCE
          role: github-users
    roles:
      realm:
        - name: github-users
          containerId: ${cluster_keycloak_realm_name}