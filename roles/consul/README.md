# Consul

Consul role for deploying and managing Consul with Docker and systemd. Variables:

| var | description | default |
|-----|-------------|---------|
| `consul_image` | Docker image to pull and run | `progrium/consul` |
| `consul_image_tag` | Docker image tag to pull and run | `latest` |
| `consul_is_server` | Consul node is a server | `yes` |
| `consul_dc` | Consul datacenter | `dc1` |
| `consul_server_group` | Consul server group for Ansible | `all` |
| `consul_advertise` | IP address Consul will advertise | auto-generated |
| `consul_retry_join` | list of IP addresses Consul contacts to rejoin the cluster on start | auto-generated list of hosts in `consul_server_group` for each `consul_dc` |
| `consul_bootstrap_expect` | number of servers to expect | auto-generated count of hosts in `consul_server_group` for each `consul_dc`|
| `consul_gossip_key` | 16-bytes base64 encoded key used to encrypt gossip communication between nodes | unset |

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
