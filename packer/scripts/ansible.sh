#!/bin/bash -eux

update-ca-trust

# Install EPEL repository
rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

# Install Ansible
yum -y install ansible
