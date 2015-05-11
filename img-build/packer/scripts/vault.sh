#!/bin/bash
set -ex

cat > /etc/yum.repos.d/stevendborrelli.repo <<EOF
[stevendborrelli]
name=stevendborrelli
baseurl=https://dl.bintray.com/stevendborrelli/rpm
gpgcheck=0
EOF

yum clean all
yum makecache -y
yum install -y vault
yum upgrade -y vault

# EOF
