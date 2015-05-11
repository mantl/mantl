#!/bin/bash
set -ex

cat > /etc/yum.repos.d/CiscoCloud.repo <<EOF
[CiscoCloud]
name=CiscoCloud
baseurl=https://dl.bintray.com/ciscocloud/rpm/
gpgcheck=0
EOF

yum clean all
yum makecache -y
yum install -y consul-ui
yum upgrade -y consul-ui

# EOF
