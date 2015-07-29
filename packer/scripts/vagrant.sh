#!/bin/bash -eux

# install the insecure public key for Vagrant
mkdir -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys
