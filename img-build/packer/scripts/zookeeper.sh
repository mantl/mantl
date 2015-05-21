#!/bin/bash
set -ex

yum clean all
yum makecache -y
yum install -y nmap-ncat
yum upgrade -y nmap-ncat

docker pull ciscocloud/zookeeper:0.2

# EOF
