#!/bin/bash
set -ex

yum clean all
yum makecache -y
yum install -y epel-release
yum install -y collectd

# EOF
