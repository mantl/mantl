#!/bin/bash
set -ex

yum install -y -t http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm | true
yum install -y marathon

# EOF
