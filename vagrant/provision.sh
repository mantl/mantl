#!/bin/bash
set -exo pipefail

yum makecache

# Append hosts if they aren't already in there
if ! [[ $(< /etc/hosts) == *"$1"* ]]; then
  echo "$1" >> /etc/hosts
fi

# enable EPEL and get sshpass if it's not already installed
if ! sshpass; then
  if ! yum list installed epel-release > /dev/null; then
    curl -f -S -s -O 'http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm'
    rpm -ivh epel-release-7-6.noarch.rpm
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
if [[ ! -f security.yml ]] || [[ ! -d ssl/ ]]; then
  mkdir -p ssl/ # avoid an error in security-setup
  ./security-setup --enable=false
  chown -R vagrant:vagrant .
fi
