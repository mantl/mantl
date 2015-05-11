#!/bin/bash
set -ex

cat > /etc/yum.repos.d/ciscocloud.repo <<EOF
[ciscocloud]
name=ciscocloud
baseurl=https://dl.bintray.com/ciscocloud/rpm/
gpgcheck=0
EOF

yum makecache -y
yum install -y consul-template
yum upgrade -y consul-template

# EOF
