# Changelog

## 1.2 (June 21, 2016)

* Mesos and Marathon improvements
  * Upgrade Mesos to 0.28.2 and Marathon to 1.1.1 #1524 (https://github.com/CiscoCloud/mantl/issues/1524)
  * Upgrade Mesos and Marathon #1514 (https://github.com/CiscoCloud/mantl/issues/1514)
  * rotate only the actual log files for mesos #1529 (https://github.com/CiscoCloud/mantl/issues/1529)
  * mesos logroate issues  #1511 (https://github.com/CiscoCloud/mantl/issues/1511)

* Packaging improvements
  * Mantl has a dedicated rpm repository per release #1466 (https://github.com/CiscoCloud/mantl/issues/1466)
  * Mantl has a dedicated rpm repository per release #1555 (https://github.com/CiscoCloud/mantl/issues/1555)

* Traefik Upgrade
  * traefik: package version 1.0.0 #1559 (https://github.com/CiscoCloud/mantl/issues/1559)
  * traefik: fixes traefik ui #1563 (https://github.com/CiscoCloud/mantl/issues/1563)

* Mutli-cloud automated testing improvements
  * TRAVIS DOCKER Install bash for provisioning #1499 (https://github.com/CiscoCloud/mantl/issues/1499)
  * dockerfile: upgrade to terraform v0.6.16 #1533 (https://github.com/CiscoCloud/mantl/issues/1533)

* Documentation improvements
  * readme: revamp supported platform section #1509 (https://github.com/CiscoCloud/mantl/issues/1509)
  * Replace CiscoCloud logo with Mantl logo in docs #1470 (https://github.com/CiscoCloud/mantl/issues/1470)
  * updated functional IP descriptions #1567 (https://github.com/CiscoCloud/mantl/issues/1567)

* AWS Provider Improvements
  * Change default vpc name to mantl #1479 (https://github.com/CiscoCloud/mantl/issues/1479)

* GCE Provider Improvements
  * gce: short_name and long_name should default to "mantl" #1503 (https://github.com/CiscoCloud/mantl/issues/1503)
  * gce: long_name and short_name should default to "mantl" #1502 (https://github.com/CiscoCloud/mantl/issues/1502)
  * gce: default network short_name to mantl #1549 (https://github.com/CiscoCloud/mantl/issues/1549)

* ELK Stack Improvements
  * Split ELK role into standalone Elasticsearch and Kibana roles #1481 (https://github.com/CiscoCloud/mantl/issues/1481)
  * inconsistent value for elasticsearch-http when using kibana-mesos #1545 (https://github.com/CiscoCloud/mantl/issues/1545)
  * Consistent kibana elasticsearch-http value #1550 (https://github.com/CiscoCloud/mantl/issues/1550)
  * elk: increase default resources #1569 (https://github.com/CiscoCloud/mantl/issues/1569)

* Calico support
  * Upgrade Calico to latest - 0.19.0 #1523 (https://github.com/CiscoCloud/mantl/issues/1523)
  * Calico with Mesos and Kubernetes integrated #1521 (https://github.com/CiscoCloud/mantl/issues/1521)

* Vault improvements
  * Lock down vault configuration file #1494 (https://github.com/CiscoCloud/mantl/issues/1494)
  * vault: verify server with TLS #1498 (https://github.com/CiscoCloud/mantl/issues/1498)
  * Vault 0.5.3 #1510 (https://github.com/CiscoCloud/mantl/issues/1510)
  * Upgrade to Vault 0.5 #1496 (https://github.com/CiscoCloud/mantl/issues/1496)

* Kafka Addon Improvements
  * kafka: create topics and cleanup config #1525 (https://github.com/CiscoCloud/mantl/issues/1525)
  * Kafka enhancements #1468 (https://github.com/CiscoCloud/mantl/issues/1468)

* Other fixes and enhancements
  * reduce code duplication in nginx_proxy.yml #1526 (https://github.com/CiscoCloud/mantl/issues/1526)
  * readme: add clc to supported platforms #1536 (https://github.com/CiscoCloud/mantl/issues/1536)
  * Update vagrant to include kubeworkers and refator edge, worker loop #1365 (https://github.com/CiscoCloud/mantl/issues/1365)
  * Remove mantl rename FAQ #1471 (https://github.com/CiscoCloud/mantl/issues/1471)
  * List cloud-init-providers in a variable #1508 (https://github.com/CiscoCloud/mantl/issues/1508)
  * Hardcode consul_dns_domain #1449 (https://github.com/CiscoCloud/mantl/issues/1449)
  * Fix jupyter example - ws not a valid config for traefik #1547 (https://github.com/CiscoCloud/mantl/issues/1547)
  * Ensure package removal url is only one line #1539 (https://github.com/CiscoCloud/mantl/issues/1539)
  * Extraneous file "test.mesos.yml" #1522 (https://github.com/CiscoCloud/mantl/issues/1522)
  * Add memory usage restrictions to Docker containers #1451 (https://github.com/CiscoCloud/mantl/issues/1451)
  * Distributive-dnsmasq 0.2.6 #1558 (https://github.com/CiscoCloud/mantl/issues/1558)
  * remove test.mesos.yml  #1552 (https://github.com/CiscoCloud/mantl/issues/1552)
  * Add playbook to force consul leader election #948 (https://github.com/CiscoCloud/mantl/issues/948)
  * Vagrant update to include Kube worker #1542 (https://github.com/CiscoCloud/mantl/issues/1542)

## 1.1 (May 13, 2016)

### Features and Improvements

* Kubernetes (Technical Preview) Support
  * Feature/k8s by default [#1302](https://github.com/CiscoCloud/mantl/pull/1302)
  * Required variable `kube_worker_ips` is not set [#1329](https://github.com/CiscoCloud/mantl/pull/1329)
  * Expose Kubernetes dashboard in Mantl UI [#1335](https://github.com/CiscoCloud/mantl/pull/1335)
  * Feature/k8s aws [#1370](https://github.com/CiscoCloud/mantl/pull/1370)
  * nginx-consul not running on kube workers [#1346](https://github.com/CiscoCloud/mantl/pull/1346)
  * flannel: start nginx-consul post docker restart [#1394](https://github.com/CiscoCloud/mantl/pull/1394)
  * nginx-consul restart issues on k8s workers [#1391](https://github.com/CiscoCloud/mantl/pull/1391)
  * Kube UI not working  [#1367](https://github.com/CiscoCloud/mantl/pull/1367)
  * k8s: consistent variable names and updated samples [#1371](https://github.com/CiscoCloud/mantl/pull/1371)
  * README: add K8S to 'core components' [#1411](https://github.com/CiscoCloud/mantl/pull/1411)
  * added kubeworker_type [#1417](https://github.com/CiscoCloud/mantl/pull/1417)
  * Update vagrant to include kubeworkers and refator edge, worker loop [#1365](https://github.com/CiscoCloud/mantl/pull/1365)
  * update kubelet hostname override [#1376](https://github.com/CiscoCloud/mantl/pull/1376)
  * Kubernetes by default [#1330](https://github.com/CiscoCloud/mantl/pull/1330)
  * cloudflare: consistent kubernetes naming in dns [#1369](https://github.com/CiscoCloud/mantl/pull/1369)
  * kubernetes: dnsimple support [#1368](https://github.com/CiscoCloud/mantl/pull/1368)
  * gitignore: ignore .syncdir/ [#1404](https://github.com/CiscoCloud/mantl/pull/1404)
  * Feature/k8s dedicated workers [#1298](https://github.com/CiscoCloud/mantl/pull/1298)

* Mutli-cloud automated testing improvements
  * Add Travis badge to front page [#1174](https://github.com/CiscoCloud/mantl/pull/1174)
  * Add travis badge to README [ci skip] [#1176](https://github.com/CiscoCloud/mantl/pull/1176)
  * Feature/slack notifications [#1275](https://github.com/CiscoCloud/mantl/pull/1275)
  * Move travis build steps into a "switchboard" run-tests script [#1249](https://github.com/CiscoCloud/mantl/pull/1249)
  * [TRAVIS] Increase timeout for health checks [#1433](https://github.com/CiscoCloud/mantl/pull/1433)
  * Testing/local script [#1382](https://github.com/CiscoCloud/mantl/pull/1382)
  * Enable security for CI testing [#1379](https://github.com/CiscoCloud/mantl/pull/1379)
  * TRAVIS rm install step, containers have deps [#1423](https://github.com/CiscoCloud/mantl/pull/1423)
  * Wrap OS ssh key decryption w/ check for fork [#1415](https://github.com/CiscoCloud/mantl/pull/1415)
  * TRAVIS remove badge from README #1442 [#1442](https://github.com/CiscoCloud/mantl/pull/1442)

* Enhanced Docker image for mantl deployments
  * Docker image-only deployments [#1261](https://github.com/CiscoCloud/mantl/pull/1261)
  * [WIP]: Feature/docker refactor [#1278](https://github.com/CiscoCloud/mantl/pull/1278)
  * Implement testing in docker containers [#1289](https://github.com/CiscoCloud/mantl/pull/1289)

* Improved vSphere support
  * Configurable root volume size on vSphere [#1097](https://github.com/CiscoCloud/mantl/pull/1097)
  * vSphere Parameter Update [#1051](https://github.com/CiscoCloud/mantl/pull/1051)
  * vSphere Provider Fixes including linked clones, folders, and private_… [#985](https://github.com/CiscoCloud/mantl/pull/985)
  * patch use builtin vsphere provider [#1297](https://github.com/CiscoCloud/mantl/pull/1297)
  * Updating vSphere Terraform Build to Support Kubernetes Worker Addition [#1340](https://github.com/CiscoCloud/mantl/pull/1340)
  * Updated vSphere Support to Master and add Kubernetes [#1469](https://github.com/CiscoCloud/mantl/pull/1469)

* CenturyLinkCloud support
  * terraform assets and support for CenturyLinkCloud [#1095](https://github.com/CiscoCloud/mantl/pull/1095)
  * terraforming fixes on ctl.io [#1311](https://github.com/CiscoCloud/mantl/pull/1311)

* Joyent Triton support
  * Add Joyent's Triton as a deploy target [#1395](https://github.com/CiscoCloud/mantl/pull/1395)
  * docs(triton): change limits link to new page [#1396](https://github.com/CiscoCloud/mantl/pull/1396)

* Documentation for on-premise, bare-metal installation
  * On-premise installation support [#847](https://github.com/CiscoCloud/mantl/pull/847)
  * Bare Metal Mantl [#1147](https://github.com/CiscoCloud/mantl/pull/1147)

* Chronos is now distributed as an addon
  * chronos marathon addon [#1260](https://github.com/CiscoCloud/mantl/pull/1260)
  * Move the Chronos scheduler to an addon [#1168](https://github.com/CiscoCloud/mantl/pull/1168)
  * chronos: fix customized installations [#1344](https://github.com/CiscoCloud/mantl/pull/1344)

* Updated to the latest available Centos 7 AMI (AWS)
  * Update Centos 7 AWS AMI [#1178](https://github.com/CiscoCloud/mantl/pull/1178)
  * Update AMIs, remove references to old ones [#1179](https://github.com/CiscoCloud/mantl/pull/1179)

* Documentation improvements
  * Split "features" section of README into core, addons, and goals [#1211](https://github.com/CiscoCloud/mantl/pull/1211)
  * Update README for accuracy, especially "features" [#1221](https://github.com/CiscoCloud/mantl/pull/1221)
  * Doc/feb16update [#1217](https://github.com/CiscoCloud/mantl/pull/1217)
  * Convert bare-metal docs to RST, add to guide [#1254](https://github.com/CiscoCloud/mantl/pull/1254)
  * Update README.md [#1243](https://github.com/CiscoCloud/mantl/pull/1243)
  * Remove mentions of terraform.sample.yml [#1162](https://github.com/CiscoCloud/mantl/pull/1162)
  * Fixed typo in roles/lvm/README.rst [#1313](https://github.com/CiscoCloud/mantl/pull/1313)
  * A few documentation fixes, mostly in getting-started [#1357](https://github.com/CiscoCloud/mantl/pull/1357)
  * Fixed hyperlink reference for Goals at TOC [#1452](https://github.com/CiscoCloud/mantl/pull/1452)

* NTP: chronyd is enabled by default
  * common: add chrony [#1213](https://github.com/CiscoCloud/mantl/pull/1213)

* Internal DNS improvements with Mantl-DNS
  * DNSMasq Configuration blocks metadata.google.internal [#1230](https://github.com/CiscoCloud/mantl/pull/1230)
  * Consul DNS Package [#1232](https://github.com/CiscoCloud/mantl/pull/1232)
  * dnsmasq: upgrade mantl-dns to 1.1.0 [#1246](https://github.com/CiscoCloud/mantl/pull/1246)
  * dnsmasq: don't get latest version [#1265](https://github.com/CiscoCloud/mantl/pull/1265)
  * dnsmasq: remove unused 10-consul file [#1290](https://github.com/CiscoCloud/mantl/pull/1290)
  * old version of /etc/dnsmasq.d/10-consul exists post upgrade of 1.0.3 -> 1.1 [#1292](https://github.com/CiscoCloud/mantl/pull/1292)
  * dnsmasq search configuration [#1377](https://github.com/CiscoCloud/mantl/pull/1377)

* Improved logging configurations to reduce verbosity and fix rotation issues
  * Turn down log levels on most chatty services [#1241](https://github.com/CiscoCloud/mantl/pull/1241)
  * consul: default log level of 'warn' [#1256](https://github.com/CiscoCloud/mantl/pull/1256)
  * Fix/mesos logrotate [#1272](https://github.com/CiscoCloud/mantl/pull/1272)
  * mesos logrotation issues [#764](https://github.com/CiscoCloud/mantl/pull/764)
  * mesos: refactor logging [#1291](https://github.com/CiscoCloud/mantl/pull/1291)

* Issue and contribution checklists
  * pull request template: remove rebase requirement [#1264](https://github.com/CiscoCloud/mantl/pull/1264)

* ELK stack refactor and improvements
  * elk addon refactor [#1312](https://github.com/CiscoCloud/mantl/pull/1312)
  * upgrade to newest version of Elasticsearch framework [#1198](https://github.com/CiscoCloud/mantl/pull/1198)
  * Move logstash role to ELK addon [#1180](https://github.com/CiscoCloud/mantl/pull/1180)
  * logstash: install on all nodes when installing elk [#1342](https://github.com/CiscoCloud/mantl/pull/1342)

* AWS Provider Enhancements
  * Adds an output for hostnames [#1234](https://github.com/CiscoCloud/mantl/pull/1234)
  * Question: Why are the aws root volumes standard not gp2 ? [#1414](https://github.com/CiscoCloud/mantl/issues/1414)
  * aws: gp2 volume type for root device [#1416](https://github.com/CiscoCloud/mantl/pull/1416)

* Openstack Provider Enhancements
  * Openstack terraform changes: Add (optional) dns_nameservers, add volu… [#1196](https://github.com/CiscoCloud/mantl/pull/1196)

* Moved collectd out of core and into an addon
  * Feature/collectd addon [#1251](https://github.com/CiscoCloud/mantl/pull/1251)

* Zookeeper stability, configurability, and maintenance improvements
  * Feature/zk purge logs [#1309](https://github.com/CiscoCloud/mantl/pull/1309)
  * Bug: enable zookeeper log purge  [#1294](https://github.com/CiscoCloud/mantl/pull/1294)
  * Increase zookeeper sync/init timeouts, add max client connections [#1348](https://github.com/CiscoCloud/mantl/pull/1348)
  * Feature/granular zk hosts [#1308](https://github.com/CiscoCloud/mantl/pull/1308)

* Ability to customize mesos agent attributes
  * Feature/mesos attributes [#1284](https://github.com/CiscoCloud/mantl/pull/1284)

* Upgraded to a more recent Traefik release
  * traefik upgrade [#1354](https://github.com/CiscoCloud/mantl/pull/1354)

* Consul 0.6.4
  * Update consul & consul-ui to 0.6.4 [#1384](https://github.com/CiscoCloud/mantl/pull/1384)
  * Consul update to 0.6.4 [#1328](https://github.com/CiscoCloud/mantl/pull/1328)

* Include docker-cleanup package by default
  * Include docker-cleanup rpm package by default, with appropriate settings. [#831](https://github.com/CiscoCloud/mantl/pull/831)

* iptables configuration variables set in Consul
  * Move iptables configuration variables to consul [#1350](https://github.com/CiscoCloud/mantl/pull/1350)

* Consolidation of consul, marathon, and mesos nginx proxies into a single container
  * Consolidate the nginx-* into a single nginx-consul container [#1347](https://github.com/CiscoCloud/mantl/pull/1347)

* Docker upgraded to 1.11.1
  * Add new partitioner script, which can do job on first boot [#1239](https://github.com/CiscoCloud/mantl/pull/1239)
  * Fix docker removal of nginx-consul [#1390](https://github.com/CiscoCloud/mantl/pull/1390)
  * Fix/docker upgrade 1.1 [#1477](https://github.com/CiscoCloud/mantl/pull/1477)

* Use a single certificate for Vault, Consul, and nginx
  * Feature/single cert [#1325](https://github.com/CiscoCloud/mantl/pull/1325)

* Kafka addon is now available
  * kafka role [#1336](https://github.com/CiscoCloud/mantl/pull/1336)

* Upgrade support for upgrading a 1.0.3 cluster
  * 1.1 upgrade playbook [#1392](https://github.com/CiscoCloud/mantl/pull/1392)
  * add playbook for upgrading a 1.0.3 cluster to 1.1 [#1407](https://github.com/CiscoCloud/mantl/pull/1407)
  * Fix distributive upgrade from Mantl 1.0.3 -> 1.1 [#1296](https://github.com/CiscoCloud/mantl/pull/1296)

* Spark example app
  * Examples/spark [#1267](https://github.com/CiscoCloud/mantl/pull/1267)
  * Examples/spark fix [#1380](https://github.com/CiscoCloud/mantl/pull/1380)

### Fixes

* error installing cloud-utils-growpart [#1257](https://github.com/CiscoCloud/mantl/pull/1257)
* docker: fix cloud-utils-growpart install [#1258](https://github.com/CiscoCloud/mantl/pull/1258)
* logstash: take any service [#1262](https://github.com/CiscoCloud/mantl/pull/1262)
* distributive symlink failures [#1259](https://github.com/CiscoCloud/mantl/pull/1259)
* New distributive packages [#1268](https://github.com/CiscoCloud/mantl/pull/1268)
* traefik: wait for marathon before starting (smlr) [#1281](https://github.com/CiscoCloud/mantl/pull/1281)
* Traefik health check warning [#1073](https://github.com/CiscoCloud/mantl/pull/1073)
* adding task during ansible-playbook to install yum-utils [#1285](https://github.com/CiscoCloud/mantl/pull/1285)
* gitignore: don't check in terraform secrets [#1315](https://github.com/CiscoCloud/mantl/pull/1315)
* logstash: clarify logstash_output_elasticsearch [#1322](https://github.com/CiscoCloud/mantl/pull/1322)
* distributive checks broken when upgrading from 1.03 to master (1.1) [#1288](https://github.com/CiscoCloud/mantl/pull/1288)
* Feature/traefik marathon enable [#1358](https://github.com/CiscoCloud/mantl/pull/1358)
* consul: turn off proxy buffering in nginx conf [#1341](https://github.com/CiscoCloud/mantl/pull/1341)
* Mesos 0.25 failing with registrar recovery timeouts [#1225](https://github.com/CiscoCloud/mantl/pull/1225)
* Add --ip option for mesos agents and master [#1310](https://github.com/CiscoCloud/mantl/pull/1310)
* Remove .node.consul from mesos hostnames [#1385](https://github.com/CiscoCloud/mantl/pull/1385)
* Add explicit dependency on libselinux-python [#1250](https://github.com/CiscoCloud/mantl/pull/1250)
* Use smlr instead of marathon-wait-for-listen.sh [#1282](https://github.com/CiscoCloud/mantl/pull/1282)
* Bring packer up to date with changes since 1.0 [#1373](https://github.com/CiscoCloud/mantl/pull/1373)
* force remove containers in systemd services [#1393](https://github.com/CiscoCloud/mantl/pull/1393)
* set persistent, friendly hostname [#1374](https://github.com/CiscoCloud/mantl/pull/1374)
* Remove storage dropin from non lvm deployments [#1410](https://github.com/CiscoCloud/mantl/pull/1410)
* vagrant: failed  msg: Destination directory /etc/cloud/cloud.cfg.d does not exist [#1408](https://github.com/CiscoCloud/mantl/pull/1408)
* Filter providers when templating to /etc/cloud/cloud.cfg.d [#1409](https://github.com/CiscoCloud/mantl/pull/1409)
* Remove duplicate "reload consul" handlers in core roles [#1405](https://github.com/CiscoCloud/mantl/pull/1405)
* Add dependency on handlers role to docker role [#1428](https://github.com/CiscoCloud/mantl/pull/1428)
* Fix typo in gce.sample.tf [#1345](https://github.com/CiscoCloud/mantl/pull/1345)
* use zookeepercli package from mantl-rpm [#1431](https://github.com/CiscoCloud/mantl/pull/1431)
* make dns and route53 names consistent with /etc/hosts [#1306](https://github.com/CiscoCloud/mantl/pull/1306)
* Eliminate a race where a mesos agent could not connect to the master [#1465](https://github.com/CiscoCloud/mantl/pull/1465)

## 1.0.3 (March 04, 2016)

### Features and Improvements

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

### Fixes

* Update mesos_cluster name to mantl! #963
* untangle collectd and docker role and document custom selinux policy #1044
* Fix vault root token persistence #1059
* Changed terraform.sample.yml to sample.yml, and terraform.yml to mantl.yml #1119
* mantl-api: run on security-disabled clusters #1145
* GCE support for Terraform v0.6.11+ #1150
* Fix collectd mesos-slave.py typo #1156
* Add condition to check for definition of "provider" #1170
* kong: update readme and use updated api endpoint #1171
* Derive defaults for `consul_is_server` variable #1215
* marathon: don't pull down docker images in advance #1218
* marathon: generate consul service before iptables #1219

## 1.0.0 (February 16, 2016)

### Features and Improvements

* Mesos 0.25 and Marathon 0.13 #955, #998
* Consul-template 0.12.2 #1012
* Consul 0.6.3 #1000
* Kong example #966, #1071
* Use Overlayfs (backed by xfs) for Docker storage #922, #1032
* Upgrade support (alpha) #1028
* mantl-api 0.1.4 (support for additional frameworks like Elasticsearch) #1086
* Multi-cloud integration testing with Travis CI #1076, #1009
* Improved vault support #1045

### Fixes

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

## 0.5.1 (December 22, 2015)

### Features

* Improved GlusterFS experience #849, #867, #868, #880, #898, #904
* Improved Zookeeper setup, configuration, and upgrade path #873, #896, #917
* Traefik UI integration #878

### Fixes

* Selinux is set to permissive mode by default #895
* Tasks using the docker containerizer can write to the Mesos sandbox #613
* Updated packaging to fix invalid Consul user shell setting #908
* Logstash configuration is now correctly configured on Mesos master and agent nodes #920, #921
* Documentation updates #839, #848, #885, #893, #936

## 0.5.0 (November 23, 2015)

### Features

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

### Fixes

* Use Centos-provided Docker package #803
* Configurable root volume size on AWS and GCE #724, #725
* Configurable stale reads in Consul #807
* Improved hosts file generation #690
* Fix for open file limits with Consul #802
* Collectd Docker plugin fixes #782
* Better timeouts for some Consul health checks #786
* Improved Ansible change detection for Docker private registries #804
* Consistent role names across cloud providers (control, worker, edge roles)

## 0.4.0 (October 29, 2015)

### Features

* Add MantlUI proxy for Mesos/Marathon/Chronos/Consul
* Add [Mantl API](http://aster.is/blog/2015/10/29/announcing-mantl-api/) support
* Add GlusterFS shared filesystem support
* Add Calico IP per container networking (tech preview)
* Add support for DNSimple DNS registration

### Fixes

* mesos-consul and marathon-consul updates to improve service discovery consistency
* terraform.py improvements with support for SoftLayer and Microsoft Azure

## 0.3.2 (June 30, 2015)

### Features

* Add Minecraft sample app #506
* Add documentation for all components that were missing it #520
* Add ElasticSearch output for Logstash #524 (see
  `logstash_output_elasticsearch` in the
  [logstash component documentation](http://docs.mantl.io/en/latest/components/logstash.html))
* Add filesystem-backed Marathon artifact store #525

### Fixes

* Update docs to clarify required Python version #515
* Fix typo in the Nginx proxy setup for Mesos #521
* Explicitly specify PyYAML version in `requirements.txt`
* Support SSH key passphrase and any key name in the Docker builder #517

## 0.3.1 (June 17, 2015)

### Features

* Add Distributive system checker #434
* Add Chronos role  #437
* Add DigitalOcean terraform provider #449
* Add VMware vSphere terraform provider #471
* Support for terraform in Dockerfile #481

### Fixes

* Use default security group in OpenStack #477
* Allow `terraform.py` to use configurable usernames #491
* Change "disable security" to "check security" in `security-setup` #494
* Stop logstash variables from showing up as a top-level component in docs #482

## 0.3.0 (June 8, 2015)

### Features

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
* Improve readability of `security-setup --help` #248
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
* Use `ciscocloud/logstash:0.2` for logstash container #443
* Add command line argument for hostname to `zookeeper-wait-for-listen.sh` #416

### Fixes

* Note Vagrant provider requirement #170
* Fix dnsmasq host #188
* Disable firewalld #193
* Have awk read /proc/uptime directly #216
* security-setup now uses proper common names #228
* serialize Consul restarts #262
* Remove use of sudo for local file modification #272
* Use CiscoCloud data volume for zookeeper container #282
* Consul requires restart on `acl_master_token` change #283
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

### Deprecations

* Mantl now uses [Terraform](https://www.terraform.io/) for provisioning hosts,
  and [terraform.py](https://github.com/CiscoCloud/terraform.py) instead of
  inventory files. Because of this change, you will need to use the new
  [Terraform-based Getting Started Guide](http://docs.mantl.io/en/latest/getting_started/index.html).

## 0.2.0 (April 10, 2015)

### Features

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

### Fixes

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


## 0.1.0 (March 2, 2015)

* Initial release.

### Ansible Roles

* Add common role for timezones, users and resolv.conf
* Add consul role
* Add dnsmasq role
* Add registrator role
* Add mesos-leader role
* Add mesos-follower role
* Add marathon role
* Add zookeeper role
* Add documentation

### Ansible Playbooks

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
