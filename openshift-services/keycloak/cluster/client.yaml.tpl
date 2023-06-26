apiVersion: keycloak.org/v1alpha1
kind: KeycloakClient
metadata:
  name: ${cluster_keycloak_client_name}
  labels:
    keycloak: ${cluster_keycloak_name}
    realm: ${cluster_keycloak_realm_name}
spec:
  realmSelector:
    matchLabels:
      keycloak: ${cluster_keycloak_name}
      realm: ${cluster_keycloak_realm_name}
  client:
    clientId: ${cluster_keycloak_client_name}
    name: ${cluster_keycloak_client_name}
    enabled: true
    baseUrl: https://oauth-openshift.${openshift_ingress_domain}/oauth2callback/${cluster_identity_provider_name}
    redirectUris:
    - https://oauth-openshift.${openshift_ingress_domain}/oauth2callback/${cluster_identity_provider_name}
    clientAuthenticatorType: client-secret
    standardFlowEnabled: true
    implicitFlowEnabled: false
    defaultClientScopes:
      - profile
      - email
      - roles
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
          id.token.claim: "true"
          access.token.claim: "true"