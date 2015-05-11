#!/bin/bash
set -ex

yum clean all
yum makecache -y
yum install -y dnsmasq bind-utils NetworkManager
yum upgrade -y dnsmasq bind-utils NetworkManager

# EOF
