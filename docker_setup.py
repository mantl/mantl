#!/usr/bin/env python2
from __future__ import print_function

import os
import os.path

from os import symlink
from os.path import exists, join
from shlex import split
from sys import exit
from subprocess import call

def link_or_generate_ssh_key():
    if 'SSH_KEY' not in os.environ:
        os.environ['SSH_KEY'] = 'id_rsa'

    ssh_key = join(os.environ['MANTL_CONFIG_DIR'], os.environ['SSH_KEY'])
    if not exists(ssh_key):
        call(split('ssh-keygen -N "" -f {}'.format(ssh_key)))

    print("Symlinking {} to /root/.ssh/id_rsa".format(ssh_key))
    symlink(ssh_key, '/root/.ssh/id_rsa')


def link_terraform_files():
    tfs = [os.path.abspath(f) for f in os.listdir(os.environ['MANTL_CONFIG_DIR'])
            if f.endswith('.tf')]
    if len(tfs):
        for tf in tfs:
            print("Symlinking {} to {}".format(tf, os.path.basename(tf)))
            symlink(tf, os.path.basename(tf))
    else:
        if 'MANTL_PROVIDER' not in os.environ:
            print("mantl.readthedocs.org for provider")
            exit(1)
        tf = 'terraform/{}.sample.tf'.format(os.environ['MANTL_PROVIDER'])

        print("Symlinking {} to mantl.tf".format(tf))
        symlink(tf, 'mantl.tf')


def link_ansible_playbook():
    ansible_playbook = join(os.environ['MANTL_CONFIG_DIR'], 'mantl.yml')
    if not exists(ansible_playbook):
        ansible_playbook = 'sample.yml'

    print("Symlinking {} to mantl.yml".format(ansible_playbook))
    symlink(ansible_playbook, 'mantl.yml')


def link_or_generate_security_file():
    security_file = join(os.environ['MANTL_CONFIG_DIR'], 'security.yml')
    if exists(security_file):
        print("Symlinking {} to security.yml".format(security_file))
        symlink(security_file, 'security.yml')
    else:
        print("Generating security.yml via security-setup")
        call(split('./security-setup --enable=false'))


if __name__ == "__main__":

    if 'MANTL_CONFIG_DIR' not in os.environ:
        print('mantl.readthedocs.org for mantl config dir')
        exit(1)

    link_or_generate_ssh_key()
    link_ansible_playbook()
    link_terraform_files()
    link_or_generate_security_file()
    exit(0)
