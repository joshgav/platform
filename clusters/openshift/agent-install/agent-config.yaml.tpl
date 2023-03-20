apiVersion: v1beta1
kind: AgentConfig
metadata:
  name: agent-config
  namespace: cluster0
# rendezvousIP may be empty if nmstateconfig is provided
# rendezvousIP: ''
rendezvousIP: 192.168.122.210
additionalNTPSources:
- 0.rhel.pool.ntp.org
- 1.rhel.pool.ntp.org
# If a host is listed, then at least one interface
# needs to be specified.
hosts: []