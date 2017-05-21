#!/bin/bash -eux

update-ca-trust

# Install EPEL repository
yum -y install epel-release

# Install Ansible
yum -y install ansible
