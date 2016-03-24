Changelog
=========

1.0.3 (March 04, 2016)
-------------------------

Features and Improvements
^^^^^^^^^^^^^^^^^^^^^^^^^

* All OS packages installed from central repositories #1193, #1204
* Elasticsearch and Kibana UIs are now available in Mantl UI #1175
* Default Kibana dashboard imported by default #1139
* ELK improvements #1191
* Addon: iptables role to restrict network traffic within the cluster #593
* Improved documentation #1106, #1153, #1160, #1161, #1163, #1164, #1169, #1181, #1222, #1227
* Update terraform.py #1105
* Mantl rename: references to microservices-insfrastructure replaced with Mantl #1134
* Pull request and issue templates #1137
* Updated Vagrant box (CiscoCloud/mantl) #1138
* Jupyter notebook example #1187

Fixes
^^^^^

* Update mesos_cluster name to mantl! #963
* untangle collectd and docker role and document custom selinux policy #1044
* Fix vault root token persistence #1059
* Changed terraform.sample.yml to sample.yml, and terraform.yml to mantl.yml #1119
* mantl-api: run on security-disabled clusters #1145
* GCE support for Terraform v0.6.11+ #1150
* Fix collectd mesos-slave.py typo #1156
* Add condition to check for definition of "provider" #1170
* kong: update readme and use updated api endpoint #1171
* Derive defaults for consul_is_server variable #1215
* marathon: don't pull down docker images in advance #1218
* marathon: generate consul service before iptables #1219

1.0.0 (February 16, 2016)
-------------------------

Features and Improvements
^^^^^^^^^^^^^^^^^^^^^^^^^

* Mesos 0.25 and Marathon 0.13 #955, #998
* Consul-template 0.12.2 #1012
* Consul 0.6.3 #1000
* Kong example #966, #1071
* Use Overlayfs (backed by xfs) for Docker storage #922, #1032
* Upgrade support (alpha) #1028
* mantl-api 0.1.4 (support for additional frameworks like Elasticsearch) #1086
* Multi-cloud integration testing with Travis CI #1076, #1009
* Improved vault support #1045

Fixes
^^^^^

* Updated mantlui nginx container tag #961
* Update traefik for go 1.5.3 fix #1035
* Tightening of permissions on Marathon configuration directories #1034, #1050
* Unify notation for file system permissions #944
* Consul ACLs #603
* Refactored AWS terraform modules #937, #870, #1090, #1074
* Refactored GCE terraform modules #964, #958
* Refactored Openstack terraform modules #901, #945, #979
* Improved documentation #906, #956, #1007, #975, #967, #1069
* DNS configuration improvements #928
* Multi-node Vagrant support #942, #1054, #1022, #977, #974
* Validate ansible version when running provisioning playbook #1019
* Require Centos 7.2 when running provisioning playbook #1020
* Improve performance of collectd docker plugin #1001
* Improved version of wait-for-hosts playbook #982
* Fixed download button in Mesos UI #955
* Updated distributive version #959
* Updated terraform version #1036
* Updated mantlui Traefik support #1075
* Fix consul rolling restart script #1070
* Cloudflare modules #902
* Replace mesosphere repo with direct links on packages #1092
* Simplify logrotate role with loops #965
* Consul DNS domain is fully configurable #1031
* Rolling and parallel versions of playbook to upgrade OS packages #1102
* Consolidated requirement validation in single playbook #1040
* PEP 0394 compatible ./security-setup #1037

0.5.1 (December 22, 2015)
-------------------------

Features
^^^^^^^^

* Improved GlusterFS experience #849, #867, #868, #880, #898, #904
* Improved Zookeeper setup, configuration, and upgrade path #873, #896, #917
* Traefik UI integration #878

Fixes
^^^^^

* Selinux is set to permissive mode by default #895
* Tasks using the docker containerizer can write to the Mesos sandbox #613
* Updated packaging to fix invalid Consul user shell setting #908
* Logstash configuration is now correctly configured on Mesos master and agent nodes #920, #921
* Documentation updates #839, #848, #885, #893, #936

0.5.0 (November 23, 2015)
-------------------------

Features
^^^^^^^^

* All-new MantlUI interface #826
* Mantl-API Integration #812
* Edge role with Traefik load balancer #821
* LVM Support #797
* Improved DNS support for DNSimple, AWS Route 53, Google Cloud DNS, and CloudFlare #748, #725, #834
* Mesos-consul support for Mesos DiscoveryPorts #796
* Kafka Logstash Output #782
* AWS support for ELB and Instance Profiles #726, #749
* Kubernetes Tech Preview #794
* Optional Docker cleanup add-on

Fixes
^^^^^

* Use Centos-provided Docker package #803
* Configurable root volume size on AWS and GCE #724, #725
* Configurable stale reads in Consul #807
* Improved hosts file generation #690
* Fix for open file limits with Consul #802
* Collectd Docker plugin fixes #782
* Better timeouts for some Consul health checks #786
* Improved Ansible change detection for Docker private registries #804
* Consistent role names across cloud providers (control, worker, edge roles)

0.4.0 (October 29, 2015)
-------------------------

Features
^^^^^^^^

* Add MantlUI proxy for Mesos/Marathon/Chronos/Consul
* Add `Mantl API <http://aster.is/blog/2015/10/29/announcing-mantl-api/>`_ support
* Add GlusterFS shared filesystem support
* Add Calico IP per container networking (tech preview)
* Add support for DNSimple DNS registration

Fixes
^^^^^

* mesos-consul and marathon-consul updates to improve service discovery consistency
* terraform.py improvements with support for SoftLayer and Microsoft Azure

0.3.2 (June 30, 2015)
---------------------

Features
^^^^^^^^

* Add Minecraft sample app #506
* Add documentation for all components that were missing it #520
* Add ElasticSearch output for Logstash #524 (see ``logstash_output_elasticsearch`` in :doc:`components/logstash`)
* Add filesystem-backed Marathon artifact store #525

Fixes
^^^^^

* Update docs to clarify required Python version #515
* Fix typo in the Nginx proxy setup for Mesos #521
* Explicitly specify PyYAML version in ``requirements.txt``
* Support SSH key passphrase and any key name in the Docker builder #517

0.3.1 (June 17, 2015)
---------------------

Features
^^^^^^^^

* Add Distributive system checker #434
* Add Chronos role  #437
* Add DigitalOcean terraform provider #449
* Add VMware vSphere terraform provider #471
* Support for terraform in Dockerfile #481

Fixes
^^^^^

* Use default security group in OpenStack #477
* Allow ``terraform.py`` to use configurable usernames #491
* Change "disable security" to "check security" in ``security-setup`` #494
* Stop logstash variables from showing up as a top-level component in docs #482

0.3.0 (June 8, 2015)
--------------------

Features
^^^^^^^^

* Performance + usage metrics Linux + Mesos + Marathon + Containers #53
* Multi OpenStack region support in Atlas (TF) #61
* Rotate all logs daily and perge weekly #158
* Add additional confirmation prompt for password in security-setup #173
* Make security-setup flags more granular #239
* Make Consul domain name configurable #100 & #156
* Deploy logstash 1.5 container to all nodes with rsyslog input and output support #164
* Enable mesos resource configurations for followers #194
* Generate SHA256 signed CA/certs by default #213
* Add support for Hashicorp Vault #225
* Add coarse-grained options to security-setup #247
* Improve readability of ``security-setup --help`` #248
* Add mesos-consul support #251
* Remove registrator for mesos-consul #263 
* Create a local host file #146
* Bootstrap Vagrant box with just 'git clone && vagrant up' #254
* Remove Registrator #255
* Clean up security-setup options #258 
* Operationalize Zookeeper #259
* Add GCE support #260
* Add AWS support #261
* Upgrade Consul to 0.5.2 #304
* Implement Consul ACL upserts #266
* Explicitly version project packages and containers #276
* Add marathon-consul support #264
* Add Logstash role #275
* Add Consul service active check script #287
* Add metadata to hosts in Openstack #290
* Update usage of argparse #296
* Move to ciscocloud/mesos-consul container #333
* Add collectd to system #335
* Remove NetworkManger dependency for dnsmasq #330
* Add Mesos collectd plugins #347
* Add docker collectd plugin. #352
* Use Consul DNS instead of .novalocal #363
* Allow different OpenStack flavors in terraform #367
* Use versioned haproxy container #369
* Add support to configure mesos-consul refresh #372
* Create OpenStack and Google Compute Engine clusters with Terraform #336
* Remove OpenStack-specific requirements and playbooks in favor of Terraform provisioning #402
* Remove ansible OpenStack playbook dependency #414
* Make logstash grab logs from ZooKeeper data volume #435
* Include collectd, logstash role in terraform sample playbook #438
* Use ``ciscocloud/logstash:0.2`` for logstash container #443
* Add command line argument for hostname to ``zookeeper-wait-for-listen.sh`` #416

Fixes
^^^^^

* Note Vagrant provider requirement #170
* Fix dnsmasq host #188
* Disable firewalld #193
* Have awk read /proc/uptime directly #216
* security-setup now uses proper common names #228
* serialize Consul restarts #262
* Remove use of sudo for local file modification #272
* Use CiscoCloud data volume for zookeeper container #282
* Consul requires restart on ``acl_master_token`` change #283
* Fix Vault restart #231
* Fix issue with Consul restart #293
* Fix Marathon race #305
* Ansible doesn't wait for Vault port to open #306
* Wait for Vault port to open #307
* Fix for "install nginx admin password" task in Consul role #313
* nginx update #317
* Updated Ansible version constraint #321
* Add ssl args to the haproxy container #370
* added openssh to image #341
* Remove ansible openstack playbooks. Fixes #402 #411
* remove inventory #424
* Bug in ansible collectd role #431
* authorize logstash syslog port when selinux enforcing #459

Deprecations
^^^^^^^^^^^^

* Mantl now uses `Terraform <https://terraform.io>`_ for
  provisioning hosts, and `terraform.py
  <https://github.com/CiscoCloud/terraform.py>`_ instead of inventory files.
  Because of this change, you will need to use the new :doc:`Terraform-based
  Getting Started Guide </getting_started/index>`.

0.2.0 (April 10, 2015)
----------------------

Features
^^^^^^^^

* Security added across the board
* Moved Consul out of docker #66
* Added authentication & ssl support for marathon #67
* Add mesos-authentication #45
* Add haproxy role to dynamically configure haproxy from Consul. #42
* Add TLS to Consul #46
* Add basic ACL support to Consul
* Add Consul agent_token support
* Add Haproxy container #42, #48
* Add authentication setup script #65
* Add Zookeeper authentication and ACLs for mesos #86
* Add nginx proxy to authentiate Consul UI
* Removed hardcoding of marathon to 0.7.6
* Move Consul to install via rpm #90
* auth-setup: openssl has to prompt user #99
* Ease of use enhancements for security-setup #109
* Need to update example/hello-world to support Marathon auth #112
* Automatically redirect http requests to https #113
* security-setup refinements #128
* Use Centos docker package #141
* Move openstack security group to a variable #155

Fixes
^^^^^
* Mesos & Marathon Consul registration do not survive reboot #16
* Set preference for virtualbox provider for owners of vmware_fusion #73
* Fix Consul clients #30
* Remove consul-ui from agent nodes #93
* OpenSSL certificate fixes #95
* Fix ansible inventory metadata #96
* Deprecated checkpoint flag prevents mesos-slave startup #105
* Consul UI unavailable #111
* Networkmanager removing 127.0.0.1 from /etc/resolv.conf #122
* Consul "Failed connect to 127.0.0.1:8080; Connection refused" #131
* Remove duplicate definition of marathon_servers #101 
* Running reboot-hosts.yml causes Consul to lose quorum #132
* Missing or incorrect information in getting started documents #133
* Numerous other bug fixes
* Docker fails to start when using latest Docker RPM without latest CentOS7 updates #161
* Fix documentation for security group ports #154
* Security-setup script hangs on low entropy linux hosts due to /dev/random bug #153


0.1.0 (March 2, 2015)
---------------------

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
