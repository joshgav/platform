#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir} && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh

namespace=app
oc create namespace ${namespace}
create_local_operatorgroup ${namespace}

echo
echo "INFO: install rhsso-operator"
create_subscription rhsso-operator ${namespace}

echo
echo "INFO: install rhsso"
oc apply -f - <<EOF
  apiVersion: keycloak.org/v1alpha1
  kind: Keycloak
  metadata:
    name: ${namespace}-keycloak
    namespace: ${namespace}
    labels:
      app: keycloak
  spec:
    externalAccess:
      enabled: true
    instances: 1
EOF

echo
echo "INFO: install realm"
oc apply -f - <<EOF
  apiVersion: keycloak.org/v1alpha1
  kind: KeycloakRealm
  metadata:
    name: ${namespace}-realm
    namespace: ${namespace}
    labels:
      app: keycloak
  spec:
    instanceSelector:
      matchLabels:
        app: keycloak
    realm:
      id: ${namespace}
      realm: ${namespace}
      displayName: ${namespace}
      enabled: true
      rememberMe: true
      userFederationProviders:
      - id: 6ee37cfc-9fcd-4815-9bc8-3d929023abf0
        displayName: msad
        providerName: ldap
        config:
          connectionUrl: ldap://msad.aws.joshgav.com:389/
          bindDn: "CN=keycloak,CN=Users,DC=aws,DC=joshgav,DC=com"
          bindCredential: "${LDAP_BIND_SECRET}"
          editMode: WRITABLE
          vendor: "ad"
          usersDn: "OU=Spring Test App,DC=aws,DC=joshgav,DC=com"
          searchScope: "2"
          userObjectClasses: "person, organizationalPerson, user"
          rdnLDAPAttribute: cn
          usernameLDAPAttribute: "sAMAccountName"
          uuidLDAPAttribute: "objectGUID"
      userFederationMappers:
      - id: a07f2780-cac7-4572-89c3-834c607ce1d9
        name: msad-group2role-mapper
        federationProviderDisplayName: msad
        federationMapperType: role-ldap-mapper
        config:
          "roles.dn": "OU=Groups,OU=Spring Test App,DC=aws,DC=joshgav,DC=com"
          mode: LDAP_ONLY
          "membership.attribute.type": "DN"
          "user.roles.retrieve.strategy": LOAD_ROLES_BY_MEMBER_ATTRIBUTE
          "membership.ldap.attribute": "member"
          "membership.user.ldap.attribute": "sAMAccountName"
          "role.name.ldap.attribute": "cn"
          "memberof.ldap.attribute": "memberOf"
          "use.realm.roles.mapping": "true"
          "role.object.classes": "group"
      - id: 4dfbd8fa-a8ca-4c3e-b7d6-f04b05302c35
        name: username
        federationProviderDisplayName: msad
        federationMapperType: user-attribute-ldap-mapper
        config:
          "ldap.attribute": sAMAccountName
          "user.model.attribute": "username"
          "is.mandatory.in.ldap": "true"
          "is.binary.attribute": "false"
          "read.only": "false"
          "always.read.value.from.ldap": "false"
EOF