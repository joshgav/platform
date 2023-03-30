# OpenShift on AWS with Installer-Provisioned Infrastructure (IPI)

Provision OpenShift clusters. Allow installer to provision infrastructure.

## Deploy cluster

1. Install [AWS][] and [openshift-install][] CLIs, and [jq](https://stedolan.github.io/jq/).
1. Set AWS access key secrets [as environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) in `.env`.
1. Get a pull secret for Red Hat's container registries from <https://console.redhat.com/openshift/downloads#tool-pull-secret>. Set this as `OPENSHIFT_PULL_SECRET` in `.env`.
1. Set up a subdomain in AWS (see [docs](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html)). Set its name as `BASE_DOMAIN` in `.env`.
1. Set `CLUSTER_NAME` and `AWS_REGION` in `.env` or rely on defaults.
1. Review cluster config in `install-config.yaml.tpl`.
1. Run `deploy.sh` to install cluster.

Run `destroy.sh` to destroy the cluster and AWS resources.

## Use cluster

Cluster state will be saved in this directory at `./_workdir/`. Rename or move this
directory to retain it so that you can later destroy the cluster or get
credentials for it. It uses Terraform and relies on its `tfstate` file.

`deploy.sh` will exit if a workdir already exists. Configure it to overwrite the
current workdir by setting env var `OVERWRITE=1`; configure it to resume a
previous installation by setting env var `RESUME=1`.

Credentials for the cluster will be echoed to stdout at the end of the
installation. You can also find these credentials in the workdir at
`./_workdir/auth`.

To use the credentials from the workdir, set `export
KUBECONFIG=$(pwd)/_workdir/auth/kubeconfig` and then use `kubectl` or `oc` as
usual.

The cluster will be accessible at this URL:
`https://console-openshift-console.apps.${CLUSTER_NAME}.${BASE_DOMAIN}`, e.g.
`https://console-openshift-console.apps.ipi.aws.joshgav.com/`.

[AWS]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[openshift-install]: https://console.redhat.com/openshift/downloads#tool-x86_64-openshift-install
