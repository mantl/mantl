#!/bin/bash -eux

# YUM cleanup
yum remove -y ansible
yum clean all

# Network cleanup
rm -f /etc/udev/rules.d/70-persistent-net.rules
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*

# Filesystem cleanup
rm -rf /tmp/*
find "$HOME" -type f -delete
find /var/log -type f -delete

# Zero out empty disk space to reduce final image size.
dd if=/dev/zero of=/null bs=1M
rm -rf /null

# sync so Packer doesn't quit before the large file is deleted
sync
