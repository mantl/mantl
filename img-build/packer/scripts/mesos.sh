#!/bin/bash
set -ex

cat > /etc/yum.repos.d/mesosphere.repo <<EOF
[mesosphere]
name=mesosphere
baseurl=http://repos.mesosphere.io/el/7/x86_64/
gpgcheck=0

[mesosphere-noarch]
name=mesosphere-noarch
baseurl=http://repos.mesosphere.io/el/7/noarch/
gpgcheck=0
EOF

yum clean all
yum makecache -y
yum install -y mesos
yum upgrade -y mesos

# EOF
