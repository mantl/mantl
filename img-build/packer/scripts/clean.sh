#!/bin/bash
set -x

# Delete to disable interface persistence.
rm -f /etc/udev/rules.d/70-persistent-net.rules

# Remove UUID and MAC address.
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*

# Purge YUM cache.
yum clean all

# Delete contents of /tmp.
rm -rf /tmp/*

# Delete files in "$HOME".
find "$HOME" -type f -delete

# Delete logs files.
find /var/log -type f -delete

# Zero out empty disk space to reduce final image size.
dd if=/dev/zero of=/null bs=1M
rm -rf /null

# EOF
