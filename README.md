
![image](./mantl-logo-1.png)

# Microservices-Infrastructure is now MANTL.

See [http://mantl.io](http://mantl.io) for more details.

Existing Developer? For information on how the rename affects you, [see our handy FAQ](./mantl-rename-faq.md)

# Overview

[![Join the chat at https://gitter.im/CiscoCloud/mantl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/CiscoCloud/mantl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Stories in Ready](https://badge.waffle.io/CiscoCloud/microservices-infrastructure.png?label=ready&title=Ready)](https://waffle.io/CiscoCloud/microservices-infrastructure)
[![Build Status](https://travis-ci.org/CiscoCloud/mantl.svg?branch=master)](https://travis-ci.org/CiscoCloud/mantl)


Mantl is a modern, batteries included platform for rapidly deploying globally distributed services

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [Overview](#overview)
    - [Features](#features)
        - [Architecture](#architecture)
        - [Control Nodes](#control-nodes)
        - [Resource Nodes](#resource-nodes)
    - [Getting Started](#getting-started)
        - [Software Requirements](#software-requirements)
        - [Deploying on multiple servers](#deploying-on-multiple-servers)
    - [Documentation](#documentation)
    - [Roadmap](#roadmap)
        - [Core Components and Features](#core-components-and-features)
        - [Mesos Frameworks](#mesos-frameworks)
        - [Security](#security)
        - [Operations](#operations)
        - [Platform Support](#platform-support)
    - [Development](#development)
    - [License](#license)

<!-- markdown-toc end -->

## Features
* [Terraform](https://terraform.io) deployment to multiple cloud providers
* [etcd](https://github.com/coreos/etcd) distributed key-value store for Calico
* [Calico](http://www.projectcalico.org) a new kind of virtual network
* [Mesos](http://mesos.apache.org) cluster manager for efficient resource isolation and sharing across distributed services
* [Marathon](https://mesosphere.github.io/marathon) for cluster management of long running containerized services
* [Consul](http://consul.io) for service discovery
* [Vault](http://vaultproject.io) for managing secrets
* [Docker](http://docker.io) container runtime
* [collectd](https://collectd.org/) for metrics collection
* [Logstash](https://github.com/elastic/logstash) for log forwarding
* [mesos-consul](https://github.com/CiscoCloud/mesos-consul) populating Consul service discovery with Mesos tasks
* [marathon-consul](https://github.com/CiscoCloud/marathon-consul) update consul k/v with Marathon tasks
* [GlusterFS](http://www.gluster.org/) for container volume storage
* [Traefik](https://traefik.github.io/) for proxying external traffic
* [Mantl API](https://github.com/CiscoCloud/mantl-api) easily install supported Mesos frameworks on Mantl
* [Mantl UI](https://github.com/CiscoCloud/nginx-mantlui) a beautiful administrative interface to Mantl
* Multi-datacenter support
* High availability
* Security

### Architecture

The base platform contains control nodes that manage the cluster and any number of resource nodes. Containers automatically register themselves into DNS so that other services can locate them.

![Single-DC](docs/_static/single_dc.png)

Once WAN joining is configured, each cluster can locate services in other data centers via DNS or the [Consul API](http://www.consul.io/docs/agent/http.html).

![Mult-DC](docs/_static/multi_dc.png)

### Control Nodes

The control nodes manage a single datacenter.  Each control node runs Consul for service discovery, Mesos leaders for resource scheduling and Mesos frameworks like Marathon.

In general, it's best to provision 3 or 5 control nodes to achieve higher availability of services. The Consul Ansible role will automatically bootstrap and join multiple Consul nodes. The Mesos Ansible role will provision highly-availabile Mesos and ZooKeeper environments when more than one node is provisioned.

![Control Node](docs/_static/control_node.png)

### Resource Nodes

Resource nodes launch containers and other Mesos-based workloads.

![Resource Node](docs/_static/resource_node.png)

### Edge Nodes

Edge nodes are responsible for proxying external traffic into services running in the cluster.

![Edge Node](docs/_static/edge_node.png)

## Getting Started

All development is done on the `master` branch. Tested, stable versions are identified via git tags.

```
    git clone https://github.com/CiscoCloud/mantl.git

```

To use a stable version, use `git tag` to list the stable versions:

```
git tag
0.1.0
0.2.0
...
0.5.0

git checkout 0.5.0
```

A Vagrantfile is provided that provisions everything on a single VM. To run, first ensure that your system has 4GB of RAM free, then:

```
sudo pip install -r requirements.txt
./security-setup
vagrant up
```

Note:
* There is no support for Windows at this time, however support is planned.
* Vagrant 1.8+ is required for best results.
* There is no support for the VMware Fusion Vagrant provider; hence your provider is set to Virtualbox in your Vagrantfile. In order to start running just issue the `vagrant up` command.

### Software Requirements

Requirements for running the project are listed in `requirements.txt`. Of note: Ansible 1.9 or later is required; also Python 2.7 is required. All the software requirements are currently distributed as Python modules, and you can `pip install -r requirements.txt` to get them all at once.

### Deploying on multiple servers

Please refer to the [Getting Started Guide](http://docs.mantl.io/en/latest/getting_started/index.html), which covers multi-server and OpenStack deployments.

## Documentation

All documentation is located at [http://docs.mantl.io](http://docs.mantl.io/en/latest).

To build the documentation locally, run:

```
sudo pip install -r requirements.txt
cd docs
make html
```

## Roadmap


### Core Components and Features

- [x] Calico
- [x] Mesos
- [x] Consul
- [x] Multi-datacenter
- [x] High availability
- [x] Rapid immutable deployment (with Terraform + Packer)

### Mesos Frameworks

- [x] Marathon
- [ ] Kubernetes
- [x] Kafka
- [ ] Riak
- [x] Cassandra
- [x] Elasticsearch
- [x] HDFS
- [ ] Spark
- [ ] Storm
- [x] Chronos
- [x] MemSQL

Note: The most up-to-date list of Mesos frameworks that are known to work with
Mantl is always in the [mantl-universe repo](https://github.com/CiscoCloud/mantl-universe).

### Security

- [x] Manage Linux user accounts
- [x] Authentication and authorization for Consul
- [x] Authentication and authorization for Mesos
- [x] Authentication and authorization for Marathon
- [x] Application load balancer (based on [Traefik](https://traefik.github.io/))
- [x] Application dynamic firewalls (using consul template)

### Operations

- [x] Logging
- [x] Metrics
- [ ] In-service upgrade with rollback
- [ ] Autoscaling of Resource Nodes
- [ ] Self maintaining system (log rotation, etc)
- [ ] Self healing system (automatic failed instance replacement, etc)

### Platform Support

- [x] Vagrant (Mac OSX + VirtualBox)
- [x] Vagrant (Linux + VirtualBox)
- [ ] Vagrant (Windows + VirtualBox)
- [x] OpenStack
- [x] Cisco Cloud Services
- [x] Cisco MetaCloud
- [ ] Cisco Unified Computing System
- [x] Amazon Web Services
- [ ] Microsoft Azure
- [x] Google Compute Engine
- [ ] VMware vSphere
- [ ] Apache CloudStack
- [x] Digital Ocean

Please see [milestones](https://github.com/CiscoCloud/mantl/milestones) for more details on the roadmap.

## Development

If you're interested in contributing to the project, install [Terraform](https://www.terraform.io/downloads.html) and the Python modules listed in `requirements.txt` and follow the Getting Started instructions. To build the docs, enter the `docs` directory and run `make html`. The docs will be output to `_build/html`.

Good issues to start with are marked with the [low hanging fruit](https://github.com/CiscoCloud/mantl/issues?q=is%3Aopen+is%3Aissue+label%3A%22low+hanging+fruit%22) tag.

## Getting Support

If you encounter any issues, please open a [Github Issue](https://github.com/CiscoCloud/mantl) against the project. We review issues daily.

We also have a [gitter chat room](https://gitter.im/CiscoCloud/mantl). Drop by and ask any questions you might have. We'd be happy to walk you through your first deployment.

[Cisco Intercloud Services](https://developer.cisco.com/cloud) provides support for OpenStack based deployments of Mantl.

## License

Copyright © 2015 Cisco Systems, Inc.

Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) (the "License").

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
