#!/usr/bin/env python2
from __future__ import print_function

import os
import os.path
import logging

from os.path import exists, join
from shlex import split
from sys import argv, exit
from subprocess import call, check_output


def symlink_force(source, link_name):
    """Equivalent to adding -f flag to bash invocation of ln"""
    if exists(link_name):
        os.remove(link_name)

    logging.info("Symlinking {} to {}".format(source, link_name))
    os.symlink(source, link_name)


def link_or_generate_ssh_keys():
    """Ensures that valid ssh keys are symlinked to /root/.ssh"""
    if 'MANTL_SSH_KEY' not in os.environ:
        os.environ['MANTL_SSH_KEY'] = 'id_rsa'

    ssh_key = join(os.environ['MANTL_CONFIG_DIR'], os.environ['MANTL_SSH_KEY'])
    if not exists(ssh_key):
        call(split('ssh-keygen -N "" -f {}'.format(ssh_key)))

    symlink_force(ssh_key, '/root/.ssh/id_rsa')
    ssh_key += '.pub'
    symlink_force(ssh_key, '/root/.ssh/id_rsa.pub')


def link_terraform_files():
    """Ensures that provided/chosen terraform files are symlinked"""
    cfg_d = os.environ['MANTL_CONFIG_DIR']
    tfs = [join(cfg_d, f) for f in os.listdir(cfg_d) if f.endswith('.tf')]
    if len(tfs):
        for tf in tfs:
            base = os.path.basename(tf)
            symlink_force(tf, base)
    else:
        if 'MANTL_PROVIDER' not in os.environ:
            logging.critical("mantl.readthedocs.org for provider")
            exit(1)
        tf = 'terraform/{}.sample.tf'.format(os.environ['MANTL_PROVIDER'])

        symlink_force(tf, 'mantl.tf')


def link_ansible_playbook():
    """Ensures that provided/sample ansible playbook is symlinked"""
    ansible_playbook = join(os.environ['MANTL_CONFIG_DIR'], 'mantl.yml')
    if not exists(ansible_playbook):
        ansible_playbook = 'sample.yml'

    symlink_force(ansible_playbook, 'mantl.yml')


def link_or_generate_security_file():
    """Ensures that security file exists and is symlinked"""
    security_file = join(os.environ['MANTL_CONFIG_DIR'], 'security.yml')
    if not exists(security_file):
        logging.info("Generating {} via security-setup".format(security_file))
        call(split('./security-setup --enable=false'))
    else:
        symlink_force(security_file, 'security.yml')


def setup():
    """Run all setup commands, saving files to MANTL_CONFIG_DIR"""
    link_or_generate_ssh_keys()
    link_ansible_playbook()
    link_terraform_files()
    link_or_generate_security_file()


def terraform():
    """Run terraform commands. Assumes that setup has been run"""
    link_or_generate_ssh_keys()
    call(split("ssh-add"))
    call(split("terraform get"))
    call(split("terraform apply -state=$TERRAFORM_STATE"))

def ansible():
    """Run ansible playbooks. Assumes that setup and terraform have been run"""
    link_or_generate_ssh_keys()
    call(split("ssh-add"))
    call(split("ansible-playbook playbooks/upgrade-packages.yml -e @security.yml"))
    call(split("ansible-playbook mantl.yml -e @security.yml"))


def ci_build():
    """Kick off a Continuous Integration job"""
    if 'TRAVIS_REPO_SLUG' in os.environ: print(os.environ['TRAVIS_REPO_SLUG'])
    link_or_generate_ssh_keys()

    commit_range_filter = 'git diff --name-only "$TRAVIS_COMMIT_RANGE" | grep -v -e \'^docs/\' -e \'md$\' -e \'rst$\''
    commit_range = check_output(commit_range_filter)
    if len(commit_range) < 1:
        logging.info("All of the changes I found were in documentation files.")
        exit(0)

    ci_branch = os.environ['TRAVIS_BRANCH']
    ci_is_pr = os.environ['TRAVIS_PULL_REQUEST']
    if ci_branch is not 'master' and ci_is_pr is False:
        logging.info("We don't want to build on pushes to branches that aren't master.")
        exit(0)

    return call(split("python2 testing/build-cluster.py"))


def ci_destroy():
    """Cleanup after ci_build"""
    link_or_generate_ssh_keys()
    for i in range(2):
        returncode = call(split("terraform destroy --force"))

    return returncode


if __name__ == "__main__":

    logfmt = "%(levelname)s\t%(asctime)s\t%(message)s"
    logging.basicConfig(format=logfmt, level=logging.INFO)

    if 'MANTL_CONFIG_DIR' not in os.environ:
        logging.critical('mantl.readthedocs.org for mantl config dir')
        exit(1)

    #TODO: replace this with either click or pypsi
    if len(argv) > 1:
        if argv[1] == 'setup':
            setup()
        elif argv[1] == 'terraform':
            terraform()
        elif argv[1] == 'ansible':
            ansible()
        elif argv[1] == 'deploy':
            setup()
            terraform()
            ansible()
        elif argv[1] == 'ci-build':
            ci_build()
        elif argv[1] == 'ci-destroy':
            ci_destroy()
        else:
            logging.critical("Usage: docker.py [CMD]")
            exit(1)
            
    else:
        logging.critical("Usage: docker.py [CMD]")
        exit(1)
