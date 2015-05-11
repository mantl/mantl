#!/bin/bash
set -ex

# Most current Docker for CentOS builds are always available in virt7-testing
# 'exclude=kernel' is to avoid newer kernels in virt7-testing
cat > /etc/yum.repos.d/virt7-testing.repo <<EOF
[virt7-testing]
name=virt7-testing
baseurl=http://cbs.centos.org/repos/virt7-testing/x86_64/os/
gpgcheck=0
exclude=kernel
EOF

yum clean all
yum makecache -y
yum install -y docker
yum upgrade -y docker

systemctl enable docker
systemctl start docker

# EOF
