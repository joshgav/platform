apiVersion: keycloak.org/v1alpha1
kind: KeycloakClient
metadata:
  name: cluster
  labels:
    keycloak: cluster
    realm: cluster
spec:
  realmSelector:
    matchLabels:
      keycloak: cluster
      realm: cluster
  client:
    clientId: cluster
    name: cluster
    enabled: true
    baseUrl: https://oauth-openshift.${openshift_ingress_domain}/oauth2callback/keycloak
    redirectUris:
    - https://oauth-openshift.${openshift_ingress_domain}/oauth2callback/keycloak
    clientAuthenticatorType: client-secret
    standardFlowEnabled: true
    directAccessGrantsEnabled: true
    implicitFlowEnabled: false
    defaultClientScopes:
      - profile
      - email
    consentRequired: false
    protocolMappers:
      - name: groups
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          claim.name: "groups"
          multivalued: "true"
          jsonType.label: "String"
          user.attribute: "foo"
          id.token.claim: "true"
          access.token.claim: "true"