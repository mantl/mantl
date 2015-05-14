#!/bin/bash
set -ex

# Use high performance kernel.org mirrors
cat > /etc/yum.repos.d/CentOS-Base.repo <<EOF
[centos-7-os]
name=centos-7-os
baseurl=https://mirrors.kernel.org/centos/7/os/x86_64/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7

[centos-7-updates]
name=centos-7-updates
baseurl=https://mirrors.kernel.org/centos/7/updates/x86_64/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7

[centos-7-extras]
name=centos-7-extras
baseurl=https://mirrors.kernel.org/centos/7/extras/x86_64/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7
EOF

# Upgrade all packages
yum clean all
yum makecache -y
yum upgrade -y

# Install httpd-tools as required for ./security-setup
yum install -y httpd-tools
yum upgrade -y httpd-tools

# Set time to Etc/UTC
rm /etc/localtime
ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime

# EOF
