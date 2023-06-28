# Platform

Configurations and scripts for development and delivery of infrastructure,
Kubernetes, platform capabilities, operators and applications.

Use the `./deploy.sh` or `./configure.sh` in any directory to apply its resources.

Most parameters are set via `.env` in the root; some are set via `.env` in the
leaf directory.

- **apps**: deploy applications that use capabilities
    - [Backstage](https://github.com/joshgav/backstage-on-openshift)
    - [spring-apiserver](https://github.com/joshgav/spring-apiserver)
    - [Quarkus Superheroes](./apps/superheroes/)
    - [Podtato-Head](./apps/podtato-head/)
- **clusters**: deploy Kubernetes and OpenShift clusters
    - [AWS IPI](./clusters/openshift/aws/ipi)
    - [AWS ROSA](./clusters/openshift/aws/rosa)
    - [Azure IPI](./clusters/openshift/azure-ipi/)
    - [Azure ARO](./clusters/openshift/aro/)
    - [Kubernetes with Kubespray](./clusters/kubespray/)
- **infrastructure**: bare metal and cloud provided compute, network and storage
- **lib**: helper scripts
- **openshift-services**: deploy capabilities on OpenShift
- **services**: deploy capabilities on Kubernetes

## LICENSE

See [LICENSE.md](LICENSE.md).