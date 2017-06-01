iptables - firewall rules
======

The iptables role limits incoming IP traffic, so that only
servers within the cluster can communicate with each other.
The iptables rules are updated dynamically using consul-template.

Some exceptions are:
- A custom whitelist of IP addresses are allowed
- SSH access is allowed from everywhere
- Consul ports are open, but rate-limited (to allow new
  members to join the cluster)

All outgoing traffic from the cluster to the Internet is
permitted. Forwarding is enabled so that docker containers
can contact each other and its host worker nodes. Every
server within the cluster can contact the docker containers.

This is a community supported addon, and will not be tested as frequently as
core Mantl components.
