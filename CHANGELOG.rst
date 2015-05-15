Changelog
=========


0.3.0 (unreleased)
------------------
Features
^^^^^^^^
* security-setup: add additional confirmation prompt for password #173
* security-setup: make security settings more granular #239
* Make consul domain name configurable #100 & #156
* enable mesos resource configurations for followers #194
* generate sha256 signed CA/certs by default #213
* Add support for Hashicorp Vault #225
* Add mesos-consul support #251
* remove registrator for mesos-consul #263 
* Create a local host file #146
* Clean up security-setup options #258 
* Upgrade to consul 0.5.1 #270
* Implement consul ACL upserts #266
* Add marathon-consul support #264

Fixes
^^^^^
* Note Vagrant provider requirement #170
* Fix/dnsmasq host #188
* update python novaclient verion #192
* disable firewalld #193
* Have awk read /proc/uptime directly #216
* security-setup now uses proper common names #228
* serialize consul restarts #262
* Remove use of sudo for local file modify #272
* Use ciscocloud data volume for zookeeper #282
* Consul requires restart on acl_master_token change #283
* Fix vault restart #231

0.2.0 (04-10-2015)
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
* Ease of use enhancements for security-setup #109
* Need to update example/hello-world to support Marathon auth #112
* Automatically redirect http requests to https #113
* security-setup refinements #128
* Use Centos docker package #141
* Move openstack security group to a variable #155

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
* Missing or incorrect information in getting started documents #133
* Numerous other bug fixes
* Docker fails to start when using latest Docker RPM without latest CentOS7 updates #161
* Fix documentation for security group ports #154
* Security-setup script hangs on low entropy linux hosts due to /dev/random bug #153


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
