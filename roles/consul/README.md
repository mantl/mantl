# Consul

Consul role, for bringing up Consul under systemd. Accepts a number of
variables:

| var | description | default |
|-----|-------------|---------|
| `image` | docker image to pull and run | `progrium/consul:latest` |
| `dc` | if set, consul will advertise this datacenter | `dc1` |
| `server_group` | group to configure join IPs from | `consul_server` |
| `interface` | interface on each host from which the IPV4 will be taken | `ansible_default_ipv4` |
| `advertise` | automatically generated as the interface on the current host | ... |
| `retry_join` | automatically generated as the `-retry-join` arguments to consul from `group` and `interface` | ... |
| `is_server` | should this node be a server or an agent? | `true` |
| `bootstrap_expect` | the number of servers to expect | auto-generated from the amount of hosts in `group` |
| `gossip_key` | if set, used to encrypt communication between nodes | unset by default |

An example playbook:

```
---
- hosts: all
  roles:
    - common
    - docker

- hosts: dc1
  roles:
    - role: consul
      gossip_key: "ggVIrhEzqe7W/65YZ9fYFA=="
      group: dc1
      dc: dc1

- hosts: dc2
  roles:
    - role: consul
      gossip_key: "ggVIrhEzqe7W/65YZ9fYFA=="
      group: dc2
      dc: dc2
```
