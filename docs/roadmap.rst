Roadmap
=======

Core Components and Features
----------------------------

| |x| Mesos
| |x| Consul
| |x| Multi-datacenter
| |x| High availablity
| |x| Rapid immutable deployment (with Terraform + Packer)

Mesos Frameworks
----------------

| |x| Marathon
| |_| Kubernetes
| |_| Kafka
| |_| Riak
| |_| Cassandra
| |_| ElasticSearch
| |_| HDFS
| |_| Spark
| |_| Storm
| |_| Chronos

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

| |_| Logging
| |_| Metrics
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
| |_| Amazon Web Services
| |_| Microsoft Azure
| |x| Google Compute Engine
| |_| VMware vSphere
| |_| Apache CloudStack
|

Please see milestones_ for more details on the roadmap.

.. _milestones: https://github.com/CiscoCloud/microservices-infrastructure/milestones
.. |_| unicode:: U+2610
.. |x| unicode:: U+2611
