Roadmap
=======

Core Components and Features
--------
| |x| Mesos
| |x| Consul
| |x| Multi-datacenter
| |x| High availablity
| |x| Rapid immutable deployment (with Terraform + Packer)

Mesos Frameworks
--------
| |x| Marathon framework
| |_| Kubernetes framework
| |_| Kafka framework
| |_| Cassandra
| |_| ElasticSearch framework
| |_| HDFS framework
| |_| Spark framework
| |_| Storm framework

Security
--------
| |x| Manage Linux user accounts
| |x| Authentication and authorization for Consul
| |x| Authentication and authorization for Mesos
| |x| Authentication and authorization for Marathon
| |x| Application load balancer (based on HAProxy and consul-template)
| |x| Application dynamic firewalls (using consul template)

Operations
--------
| |_| Logging
| |_| Metrics
| |_| In-service upgrade with rollback
| |_| Autoscaling of Resource Nodes
| |_| Self maintaining system (log rotation, etc)
| |_| Self healing system (automatic failed instance replacement, etc)

Platform Support
--------
| [x] Vagrant (Mac OSX + VirtualBox)
| [ ] Vagrant (Windows + VirtualBox)
| |x| OpenStack
| |x| Cisco Cloud Services
| |x| Cisco MetaCloud
| |_| Cisco Unified Computing System
| |_| Amazon Web Services
| |_| Microsoft Azure
| |_| Google Compute Engine
| |_| VMware vSphere
| |_| Apache CloudStack
|

Please see milestones_ for more details on the roadmap.

.. _milestones: https://github.com/CiscoCloud/microservices-infrastructure/milestones
.. |_| unicode:: U+2610
.. |x| unicode:: U+2611
