#!/bin/sh
set -e

python2 -c "import docker_setup; docker_setup.link_or_generate_ssh_keys()"
eval $(ssh-agent) && ssh-add
terraform get
terraform apply -state=$TERRAFORM_STATE
ansible-playbook /mantl/playbooks/wait-for-hosts.yml
ansible-playbook mantl.yml -e @security.yml
