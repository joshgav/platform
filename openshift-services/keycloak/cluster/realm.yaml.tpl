apiVersion: keycloak.org/v1alpha1
kind: KeycloakRealm
metadata:
  name: cluster
  labels:
    keycloak: cluster
    realm: cluster
spec:
  instanceSelector:
    matchLabels:
      keycloak: cluster
  realm:
    id: cluster
    realm: cluster
    enabled: true
    displayName: cluster
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
          containerId: "cluster"