# Configuration

## IDPs

### Google

When mapping method `lookup` is specified then individual identities must be manually added for logon to work.
I was able to find the "Google Identity Number" required in the OAuth pod logs after an unsuccessful log attempt, and saved that value as `GOOGLE_IDENTITY_NUMBER` in my `~/.env` file. This is far from ideal; perhaps in the future I can figure out a way to automate it.

```bash
# create an IDP useable by all Gmail users
# requires mapping method lookup, which requires preconfigured individual identity numbers, see note above
rosa create idp --cluster ${CLUSTER_NAME} --type google \
    --name Gmail \
    --mapping-method lookup \
    --client-id "${GOOGLE_SIGNIN_CLIENT_ID}" \
    --client-secret "${GOOGLE_SIGNIN_CLIENT_SECRET}"

rosa create idp --cluster ${CLUSTER_NAME} --type google \
    --name Google \
    --mapping-method claim \
    --client-id "${GOOGLE_SIGNIN_CLIENT_ID}" \
    --client-secret "${GOOGLE_SIGNIN_CLIENT_SECRET}" \
    --hosted-domain redhat.com

if [[ -n "${GOOGLE_IDENTITY_NUMBER}" ]]; then
    # rosa grant user cluster-admin --user=${GOOGLE_IDENTITY_NAME} --cluster=${CLUSTER_NAME}
    # rosa grant user cluster-admin --user=jgavant@redhat.com --cluster=${CLUSTER_NAME}

    oc create identity Gmail:${GOOGLE_IDENTITY_NUMBER}
    oc create user ${GOOGLE_IDENTITY_NAME} --full-name="${GOOGLE_IDENTITY_FULLNAME}"
    oc create useridentitymapping Gmail:${GOOGLE_IDENTITY_NUMBER} ${GOOGLE_IDENTITY_NAME}
    oc adm policy add-cluster-role-to-user cluster-admin ${GOOGLE_IDENTITY_NAME}
fi
```

### GitHub

Instructions:
1. Use an existing GitHub OAuth app at <https://github.com/organizations/joshgav-org/settings/applications>, or create a new one at <https://github.com/organizations/joshgav-org/settings/applications/new>
  - Note: There is no documentation on using [GitHub apps](https://github.com/organizations/joshgav-org/settings/apps), only OAuth apps.
2. Learn from the following to create an OAuth app in GitHub and configure ROSA for it:

```bash
CLUSTER_NAME=rosa1
github_idp_name='GitHub'
github_org_name='joshgav-org'
cluster_base_domain=$(rosa describe cluster --cluster ${CLUSTER_NAME} -ojson | jq -r '.dns.base_domain')
callback_url="https://oauth.${CLUSTER_NAME}.${cluster_base_domain}/oauth2callback/${github_idp_name}"
application_url="https://console-openshift-console.apps.rosa.${cluster_base_domain}"
GITHUB_OAUTH_CLIENT_ID=''
GITHUB_OAUTH_CLIENT_SECRET=''

rosa create idp --cluster ${CLUSTER_NAME} --type github \
    --name ${github_idp_name} \
    --mapping-method claim \
    --organizations ${github_org_name} \
    --client-id ${GITHUB_OAUTH_CLIENT_ID} \
    --client-secret ${GITHUB_OAUTH_CLIENT_SECRET}
```

3. Grant "cluster-admin" permissions to users based on their GitHub ID:

```bash
github_id=joshgav
rosa grant user cluster-admin -u ${github_id} -c ${CLUSTER_NAME}
```

# Machines

## extra machine pool

```bash
max_replicas=20
instance_type=m6i.4xlarge
az=use2-az1
rosa create machinepool --cluster ${CLUSTER_NAME} \
    --name ${az}-pool \
    --enable-autoscaling \
    --instance-type ${instance_type} \
    --max-replicas ${max_replicas} \
    --min-replicas 2
```