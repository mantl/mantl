#!/bin/bash
set -x

# Kernel modules are compiled during install of VirtualBox Guest Additions. The
# following list of RPMs are required to successful build these modules. Once
# built it is safe to remove these RPMs including any installed dependencies.
# Removing the RPMs reduces the size of the final VM image.
rpm -qa > 0.lst
yum install -y make bzip2 gcc kernel-devel kernel-headers
rpm -qa > 1.lst

# Install VirtualBox Guest Additions.
mount -o loop "VBoxGuestAdditions_$(cat vbox_version).iso" /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

# Uninstall RPMs and their dependencies.
yum remove -y $(join -v 2 <(sort 0.lst) <(sort 1.lst))

# Delete miscellaneous files.
rm -f "VBoxGuestAdditions_$(cat vbox_version).iso"
rm -f vbox_version
rm -f 0.lst
rm -f 1.lst

# EOF
