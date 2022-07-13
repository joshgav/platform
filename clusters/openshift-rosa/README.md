# Red Hat OpenShift on AWS (ROSA)

1. Get a token from <https://console.redhat.com/openshift/token/rosa> and put it in `.env`.
1. Run `deploy.sh`.
    - You'll have to click through prompts as the `--yes` parameters are not respected.

At the end an admin user will be created and the password will be printed to
stdout. The API and Console URLs will also be printed. Use these to login via
CLI as follows:

```bash
oc login "https://API_URL" --username cluster-admin --password "PASSWORD"

## for example:
oc login https://api.rosa1.n9km.p1.openshiftapps.com:6443 \
   --username cluster-admin --password HRppn-5IKNZ-oZHQh-XbbQ2
```
