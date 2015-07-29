#!/bin/bash -eux

# Remove ansible
yum remove -y ansible

# Zero out the rest of the free space using dd, then delete the written file.
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# sync so Packer doesn't quit before the large file is deleted
sync
