# Provision a libvirt VM

From this directory run `make [ machine | network | ssh ]` to make the machine,
network and ssh to it.

Once the machine and cluster is up, run `make volumes` to create 5 local volumes
and corresponding persistent volumes in a connected cluster.