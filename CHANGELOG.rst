Changelog
=========

0.2.0 (unreleased)
------------------

Features
^^^^^^^^

* Security added across the board
* Moved consul out of docker #66
* Added authentication & ssl support for marathon #67
* Add mesos-authentication #45
* Add haproxy role to dynamically configure haproxy from consul. #42
* Add TLS to consul #46
* Add basic ACL support to Consul
* Add consul agent_token support
* Add Haproxy container #42, #48
* Add authentication setup script #65
* Add Zookeeper authentication and ACLs for mesos #86
* Add nginx proxy to authentiate consul UI
* Removed hardcoding of marathon to 0.7.6
* Move consul to install via rpm #90
* auth-setup: openssl has to prompt user #99
* Ease of use enhancements for auth-setup #109
* Need to update example/hello-world to support Marathon auth #112
* Automatically redirect http requests to https #113
* auth-setup refinements #128
* Use Centos docker package #141

Fixes
^^^^^
* Mesos & Marathon consul registration do not survive reboot #16
* Set preference for virtualbox provider for owners of vmware_fusion #73
* Fix consul clients #30
* Remove consul-ui from agent nodes #93
* OpenSSL certificate fixes #95
* Fix ansible inventory metadata #96
* Deprecated checkpoint flag prevents mesos-slave startup #105
* Consul UI unavailable #111
* Networkmanager removing 127.0.0.1 from /etc/resolv.conf #122
* Consul "Failed connect to 127.0.0.1:8080; Connection refused" #131
* Remove duplicate definition of marathon_servers #101 
* Running reboot-hosts.yml causes consul to lose quorum #132
* Numeous other bug fixes

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
