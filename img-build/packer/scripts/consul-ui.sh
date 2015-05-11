#!/bin/bash
set -ex

cat > /etc/yum.repos.d/ciscocloud.repo <<EOF
[ciscocloud]
name=ciscocloud
baseurl=https://dl.bintray.com/ciscocloud/rpm/
gpgcheck=0
EOF

yum makecache -y
yum install -y consul-ui
yum upgrade -y consul-ui

# EOF
