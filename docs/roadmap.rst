Roadmap
=======

Core Components and Features
----------------------------

| |x| Calico
| |x| Mesos
| |x| Consul
| |x| Multi-datacenter
| |x| High availablity
| |x| Rapid immutable deployment (with Terraform + Packer)

Mesos Frameworks
----------------

| |x| Marathon
| |_| Kubernetes
| |x| Kafka
| |_| Riak
| |x| Cassandra
| |x| ElasticSearch
| |x| HDFS
| |_| Spark
| |_| Storm
| |_| Chronos
| |x| MemSQL

Note: The most up-to-date list of Mesos frameworks that are known to work with
Mantl is always in the [mantl-universe repo](https://github.com/CiscoCloud/mantl-universe).

Security
--------

| |x| Manage Linux user accounts
| |x| Authentication and authorization for Consul
| |x| Authentication and authorization for Mesos
| |x| Authentication and authorization for Marathon
| |x| Application load balancer (based on HAProxy and consul-template)
| |x| Application dynamic firewalls (using consul template)

Operations
----------

| |x| Logging
| |x| Metrics
| |_| In-service upgrade with rollback
| |_| Autoscaling of Resource Nodes
| |_| Self maintaining system (log rotation, etc)
| |_| Self healing system (automatic failed instance replacement, etc)

Platform Support
----------------

| |x| Vagrant (Mac OSX + VirtualBox)
| |x| Vagrant (Linux + VirtualBox)
| |_| Vagrant (Windows + VirtualBox)
| |x| OpenStack
| |x| Cisco Cloud Services
| |x| Cisco MetaCloud
| |_| Cisco Unified Computing System
| |x| Amazon Web Services
| |_| Microsoft Azure
| |x| Google Compute Engine
| |_| VMware vSphere
| |_| Apache CloudStack
| |_| Digital Ocean

Please see milestones_ for more details on the roadmap.

.. _milestones: https://github.com/CiscoCloud/mantl/milestones
.. |_| unicode:: U+2610
.. |x| unicode:: U+2611
