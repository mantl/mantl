#!/bin/bash
set -e

SSH_KEY=${SSH_KEY:-"/root/.ssh/id_rsa"}

eval `ssh-agent -s` && ssh-add $SSH_KEY

if [ ! -f ./security.yml ]; then
    ./security-setup --enable=false
fi

terraform get
terraform apply -state=$TERRAFORM_STATE_ROOT/terraform.tfstate
ansible-playbook /mi/playbooks/wait-for-hosts.yml --private-key $SSH_KEY
ansible-playbook /mi/terraform.yml --extra-vars=@security.yml --private-key $SSH_KEY
