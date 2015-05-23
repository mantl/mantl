#!/bin/bash
set -ex

yum install -y nmap-ncat

docker pull ciscocloud/zookeeper:0.2

# EOF
