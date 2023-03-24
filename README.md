# devenv

Configurations and scripts for development and delivery of infrastructure,
Kubernetes, platform capabilities, operators and applications.

Use the `./deploy.sh` in any directory.

Most parameters are set via `.env` in the root; some are set via `.env` in the
leaf directory.

- **apps**: deploy applications that use capabilities
- **clusters**: deploy Kubernetes and OpenShift clusters
- **docs**: extra info about some capabilities
- **infrastructure**: bare metal and cloud provided compute, network and storage
- **lib**: helper scripts
- **openshift-services**: deploy capabilities on OpenShift
- **operators**: scaffold custom operators
- **services**: deploy capabilities on Kubernetes

## LICENSE

See [LICENSE.md](LICENSE.md).