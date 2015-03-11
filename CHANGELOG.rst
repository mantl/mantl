Changelog
=========

0.2.0 (unreleased)
------------------

Features
^^^^^^^^
* Moved consul out of docker #66
* Added authentication & ssl  support for marathon #67
* Add mesos-authentication #45
* Add haproxy role to dynamically configure haproxy from consul. #42
* Add TLS to consul

Fixes
^^^^^
* Set preference for virtualbox provider for owners of vmware_fusion #73
* Fix consul clients #30

0.1.0 (03-02-2015)
------------------

- Initial release.

Ansible Roles 
^^^^^^^^^^^^^

* Add common role for timezones, users and resolv.conf
* Add consul role
* Add dnsmasq role
* Add registrator role
* Add mesos-leader role
* Add mesos-follower role
* Add marathon role
* Add zookeeper role
* Add documentation

Ansible Playbooks
^^^^^^^^^^^^^^^^^

* Add consul-join-wan
* Add destroy-hosts
* Add provision-consul-gossip-key
* Add provision-hosts
* Add provision-nova-key
* Add reboot-hosts
* Add show-containers
* Add show-package-drift
* Add show-uptime
* Add trace-consul-wan-traffic
* Add upgrade-packages
