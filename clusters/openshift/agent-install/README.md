# Agent-Based Installation

## Use

- Download and install `openshift-install` installer program from <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/>
    - e.g., `curl -#LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-install-linux.tar.gz`
- Run `./prepare.sh` to create an agent-install ISO based on config in `install-config.yaml.tpl`, `agent-config.yaml.tpl` and extra manifests in `./extras`.
    - Set `rendezvousIP` in agent-config and `machineNetwork` in install-config to match the static IP address (or DHCP reservation) for the first node.
    - To specify a DHCP reservation in libvirt, run `virsh net-edit default` and add to `network.ip.dhcp`: `<host mac="00:16:3e:3e:a9:1a" name="master0" ip="192.168.122.210"/>`
- Mount the ISO to a VM and start it.
- To add manifests to be deployed immediately after cluster installation put them in `./extras`.

## Resources
- https://docs.openshift.com/container-platform/4.12/installing/installing_with_agent_based_installer/preparing-to-install-with-agent-based-installer.html