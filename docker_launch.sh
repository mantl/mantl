#!/bin/sh
set -e

eval $(ssh-agent) && ssh-add
terraform get
terraform apply -state=$TERRAFORM_STATE
ansible-playbook /mantl/playbooks/wait-for-hosts.yml
ansible-playbook mantl.yml -e @security.yml
