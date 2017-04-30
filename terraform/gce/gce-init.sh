#!/usr/bin/env bash

set -e

sudo yum -y install cloud-init cloud-initramfs-tools
sudo reboot
