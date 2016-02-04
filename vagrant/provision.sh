#!/bin/bash
set -ex

yum makecache

# Append hosts if they aren't already in there
if ! [[ $(< /etc/hosts) == *"$1"* ]]; then
  echo "$1" >> /etc/hosts
fi

# enable EPEL and get sshpass if it's not already installed
if ! sshpass; then
  if ! yum list installed epel-release > /dev/null; then
    curl -O 'http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm'
    rpm -ivh epel-release-7-5.noarch.rpm
  fi
  yum install -y --enablerepo=epel sshpass
fi

# Install required packages if they aren't already present
for pkg in gcc python-virtualenv libselinux-python; do
  yum list installed "$pkg" > /dev/null || yum install -y "$pkg"
done
pip --version > /dev/null || easy_install pip
pip install -r /vagrant/requirements.txt

cd /vagrant
chown -R vagrant:vagrant /vagrant

# security.yml and ssl/ are stored in a directory that is preserved across
# reboots/reloads/rsyncs
semi_permanent=/security-backup
mkdir -p "$semi_permanent"

if [ ! -f security.yml ] || [ ! -d ssl/ ]; then
  # If there are backups, restore them here
  if [ -f $semi_permanent/security.yml ] && [ -d $semi_permanent/ssl/ ]; then
    cp    $semi_permanent/security.yml .
    cp -a $semi_permanent/ssl .
  else
    # Otherwise, create new ones and back them up
    mkdir -p ssl/ # avoid an error in security-setup
    ./security-setup --enable=false
    chown -R vagrant:vagrant "$PWD"
    cp    security.yml $semi_permanent
    cp -a ssl $semi_permanent
  fi
fi
