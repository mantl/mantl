# Consul

Consul role for deploying and managing Consul with Docker and systemd. Variables:

| var | description | default |
|-----|-------------|---------|
| `consul_image` | docker image to pull and run | `progrium/consul` |
| `consul_image_tag` | docker image tag to pull and run | `latest` |
| `consul_is_server` | consul node is a server | `yes` |
| `consul_dc` | if set, consul will advertise this datacenter | `dc1` |
| `consul_server_group` | group of consul servers | `all` |
| `consul_advertise` | automatically generated as the interface on the current host | ... |
| `consul_retry_join` | automatically generated as the `-retry-join` arguments to consul from `consul_server_group` | ... |
| `consul_bootstrap_expect` | number of servers to expect | auto-generated from the amount of hosts in `consul_server_group` |
| `consul_gossip_key` | 16-bytes base64 encoded key used to encrypt gossip communication between nodes | unset by default |

An example playbook:

```
---
- hosts: all
  roles:
    - common
    - docker

- hosts: host-01
  roles:
    - role: consul
  vars:
    consul_server_group: all
    consul_dc: dc1

- hosts: host-02
  roles:
    - role: consul
  vars:
    consul_server_group: all
    consul_dc: dc2
```
