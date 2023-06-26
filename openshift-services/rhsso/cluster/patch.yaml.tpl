[{
    "op": "add",
    "path": "/spec/identityProviders/-",
    "value": {
        "name": "keycloak",
        "mappingMethod": "claim",
        "type": "OpenID",
        "openID": {
            "clientID": "${cluster_keycloak_client_name}",
            "clientSecret": {
              "name": "${cluster_keycloak_client_secret_name}"
            },
            "issuer": "https://keycloak-${cluster_iam_namespace}.${openshift_ingress_domain}/auth/realms/${cluster_keycloak_realm_name}",
            "claims": {
                "preferredUsername": ["preferred_username"],
                "name": ["name"],
                "email": ["email"],
                "groups": ["groups"]
            }
        }
    }
}]
