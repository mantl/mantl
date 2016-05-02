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
        call(split('./security-setup'))
    else:
        symlink_force(security_file, 'security.yml')


def ci_setup():
    """Run all setup commands, saving files to MANTL_CONFIG_DIR"""

    if 'OS_IP' in os.environ:
        ssh_key_path = '/local/ci'
        os.chmod(ssh_key_path, 0400)

        # This string will be collapsed into one line
        # I made this change for readability
        ssh_cmd = '''
ssh -i {keypath} -p {ssh_port}
-o BatchMode=yes -o StrictHostKeyChecking=no
travis@{ssh_ip} /bin/sh -c "
mkdir --parents mantl/{commit};
git clone https://github.com/CiscoCloud/mantl.git mantl/{commit};
cd mantl/{commit};
git checkout {commit};
ln -sf {tf_file} terraform.tf;
ln -sf sample.yml mantl.yml;
./security-setup;
echo 'build_number = \\"{build}\\"' > terraform.tfvars"
        '''
        ssh_cmd = ssh_cmd.format(commit=os.environ['CI_HEAD_COMMIT'],
                keypath='/local/ci',
                ssh_port=os.environ['OS_PRT'],
                ssh_ip=os.environ['OS_IP'],
                tf_file=os.environ['TERRAFORM_FILE'],
                build=os.environ['TF_VAR_build_number'])
        ssh_cmd = " ".join(ssh_cmd.splitlines())

        exit(call(split(ssh_cmd)))
    else:
        logging.info("Running setup for cloud-providers")
        link_or_generate_ssh_keys()
        call("ssh-add")
        link_ansible_playbook()
        link_or_generate_security_file()


def ci_build():
    """Kick off a Continuous Integration job"""
    link_or_generate_ssh_keys()
    call("ssh-add")
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
    if ci_branch != 'master' and ci_is_pr != "1":
        logging.info("We don't want to build on pushes to branches that aren't master.")
        exit(0)

    if 'OS_IP' in os.environ:
        ssh_cmd = '''
ssh -i {keypath} -p {ssh_port}
-o BatchMode=yes -o StrictHostKeyChecking=no
travis@{ssh_ip} /bin/sh -c '
eval $(ssh-agent);
ssh-add;
cd ./mantl/{commit};
python2 ./testing/build-cluster.py'
        '''
        ssh_cmd = ssh_cmd.format(commit=os.environ['CI_HEAD_COMMIT'],
                keypath='/local/ci',
                ssh_port=os.environ['OS_PRT'],
                ssh_ip=os.environ['OS_IP'])
        ssh_cmd = " ".join(ssh_cmd.splitlines())

        exit(call(split(ssh_cmd)))

    else:
        logging.info("Starting cloud provider test")
        exit(call(split("python2 testing/build-cluster.py")))


def ci_destroy():
    """Cleanup after ci_build"""

    destroy_cmd = "terraform destroy -force"
    if 'OS_IP' in os.environ:
        ssh_cmd = '''
ssh -i {keypath} -p {ssh_port}
-o BatchMode=yes -o StrictHostKeyChecking=no
travis@{ssh_ip} /bin/sh -c '
kill -s SIGTERM $SSH_AGENT_PID;
cd mantl/{commit};
{destroy};
cd ..;
rm -fr {commit}'
        '''
        destroy_cmd = ssh_cmd.format(destroy=destroy_cmd,
                keypath='/local/ci',
                ssh_port=os.environ['OS_PRT'],
                ssh_ip=os.environ['OS_IP'],
                commit=os.environ['CI_HEAD_COMMIT'])
        destroy_cmd = " ".join(destroy_cmd.splitlines())
    else:
        logging.info("Destroying cloud provider resources")
        link_or_generate_ssh_keys()
        call("ssh-add")
        link_ci_terraform_file()


    exit(call(split(destroy_cmd)))


if __name__ == "__main__":

    logfmt = "%(asctime)s  %(levelname)s  %(message)s"
    logging.basicConfig(format=logfmt, level=logging.INFO)

    if 'MANTL_CONFIG_DIR' not in os.environ:
        exit(1)

    #TODO: replace this with either click or pypsi
    if len(argv) > 1:
        if argv[1] == 'ci-setup':
            ci_setup()
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
