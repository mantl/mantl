#!/bin/bash -eux
VBOXADDITIONS=/home/vagrant/VBoxGuestAdditions_4.3.26.iso

# install dependencies
yum install -y dkms bzip2

# Mount the disk image
cd /tmp
mkdir /tmp/isomount
mount -t iso9660 $VBOXADDITIONS /tmp/isomount

# Install the drivers
/tmp/isomount/VBoxLinuxAdditions.run

# Cleanup
umount isomount
rm -rf isomount # $VBOXADDITIONS
