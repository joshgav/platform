# Google SSO for OpenShift

Configures two identity providers from Google SSO for Openshift:

1. Mapped to a specific domain and using the `claim` mappingMethod.
1. Open to all domains and using the `lookup` mappingMethod.

Unfortunately, you must manually add redirect URIs to your Google SSO OAuth
client configuration at <https://console.cloud.google.com/apis/credentials>.
Select (or create) a OAuth 2.0 client and add these redirect URIs:

```
- https://oauth-openshift.apps.${CLUSTER_NAME}.${BASE_DOMAIN}/oauth2callback/Google
- https://oauth-openshift.apps.${CLUSTER_NAME}.${BASE_DOMAIN}/oauth2callback/Gmail
```

## Notes

With the `claim` or `add` mapping methods and the Google IDP, `hostedDomain`
must also be specified and constrained to a specific domain like `redhat.com`.
That is, one can't accept `gmail.com` logins this way :(.

To enable login by any @gmail.com address you must use the `lookup` mapping
method and then manually add for each user an identity and useridentitymapping
binding them to their numeric Google ID. One place (the only one I've found) to
find this numeric ID is in the logs of the `oauth-openshift` pods in the
`openshift-authentication` namespace after a failed login, as follows:

```txt
AuthenticationError: lookup of user for "Gmail:444039342934081910199" failed:
useridentitymapping.user.openshift.io "Gmail:444039342934081910199" not found
```

Use this numeric Google ID to manually add a user like this, replacing the values
for the variables. If you set info about an identity in this directory's .env
file then the configure.sh script will add it as a cluster-admin for you.

```bash
numeric_id=444039342934081910199
email=jack@gmail.com
full_name="Jack"

oc create identity Gmail:${numeric_id}
oc create user ${email} --full-name="${full_name}"
oc create useridentitymapping Gmail:${numeric_id} ${email}
oc adm policy add-cluster-role-to-user cluster-admin ${email}
```