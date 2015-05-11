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
yum install -y consul-template
yum upgrade -y consul-template

# EOF
