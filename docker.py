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


def link_ci_terraform_file():
    tf_file = os.environ['TERRAFORM_FILE']
    if exists(tf_file):
        symlink_force(os.environ['TERRAFORM_FILE'], 'terraform.tf')


def link_user_defined_terraform_files():
    """Ensures that provided/chosen terraform files are symlinked"""

    # Symlink tf files in the config dir
    cfg_d = os.environ['MANTL_CONFIG_DIR']
    tfs = [join(cfg_d, f) for f in os.listdir(cfg_d) if f.endswith('.tf')]
    if len(tfs):
        for tf in tfs:
            base = os.path.basename(tf)
            symlink_force(tf, base)
    else:
        # Symlink tf files based on provider
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


def ci_setup():
    """Run all setup commands, saving files to MANTL_CONFIG_DIR"""
    link_or_generate_ssh_keys()
    link_ansible_playbook()
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
    link_or_generate_ssh_keys()
    link_ci_terraform_file()

    # Take different action for PRs from forks
    if not os.environ['TRAVIS_REPO_SLUG'].startswith('CiscoCloud/'):
        logging.warning("Because we can't unlock deploy keys for forks of the main project, we are going to make some prelim checks, then get back to you!")
        logging.critical("Fork checks have not been implemented.")
        exit(0)

    # Filter out commits that are documentation changes.
    commit_range_cmd = 'git diff --name-only {}'.format(os.environ['TRAVIS_COMMIT_RANGE'])

    commit_range_str = str(check_output(split(commit_range_cmd)))

    commit_range = []
    for commit in commit_range_str.split():
        if commit.startswith('docs'): 
            logging.info("Modified file in docs directory: %s", commit)
        elif commit.endswith('md'): 
            logging.info("Modified file has markdown extension: %s", commit)
        elif commit.endswith('rst'): 
            logging.info("Modified file has reST extension: %s", commit)
        else:
            logging.info("Modified file not marked as docfile: %s", commit)
            commit_range.append(commit)

    if len(commit_range) < 1:
        logging.info("All of the changes I found were in documentation files. Skipping build")
        exit(0)

    # Filter out commits that are pushes to non-master branches
    ci_branch = os.environ['TRAVIS_BRANCH']
    ci_is_pr = os.environ['TRAVIS_PULL_REQUEST']
    if ci_branch is not 'master' and ci_is_pr is False:
        logging.info("We don't want to build on pushes to branches that aren't master.")
        exit(0)

    if os.environ['TERRAFORM_FILE'] == 'OPENSTACK':
        logging.critical("SSHing into jump host to test OpenStack is currently being implemented")
        ssh_key_path = '/local/ci'
        os.chmod(ssh_key_path, 0400)

        ssh_cmd = "cd mantl; git checkout --detach {}; python2 testing/build-cluster.py".format(os.environ['TRAVIS_COMMIT'])
        ssh_cmd = 'ssh -i {} -p {} -o BatchMode=yes -o StrictHostKeyChecking=no travis@{} "{}"'.format(ssh_key_path, os.environ['OS_PRT'], os.environ['OS_IP'], ssh_cmd)

        exit(call(split(ssh_cmd)))

    else:
        logging.info("Starting cloud provider test")
        exit(call(split("python2 testing/build-cluster.py")))


def ci_destroy():
    """Cleanup after ci_build"""
    link_or_generate_ssh_keys()
    link_ci_terraform_file()

    destroy_cmd = "terraform destroy --force"
    if os.environ['TERRAFORM_FILE'] == 'OPENSTACK': 
        destroy_cmd = "ssh -i {} -p {} -o BatchMode=yes -o StrictHostKeyChecking=no travis@{} '{}'".format('/local/ci', os.environ['OS_PRT'], os.environ['OS_IP'], destroy_cmd)

    for i in range(2):
        returncode = call(split(destroy_cmd))

    exit(returncode)


if __name__ == "__main__":

    logfmt = "%(levelname)s\t%(asctime)s\t%(message)s"
    logging.basicConfig(format=logfmt, level=logging.INFO)

    if 'MANTL_CONFIG_DIR' not in os.environ:
        logging.critical('mantl.readthedocs.org for mantl config dir')
        exit(1)

    #TODO: replace this with either click or pypsi
    if len(argv) > 1:
        if argv[1] == 'ci-setup':
            ci_setup()
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
