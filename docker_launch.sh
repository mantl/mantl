#!/bin/bash
set -e

SSH_KEY=${SSH_KEY:-"/root/.ssh/id_rsa"}

if [ ! -f "$SSH_KEY" ]; then
    mkdir -p /root/.ssh/
    find /ssh/* ! -type l -print0 | xargs -0 cp -t /root/.ssh/
fi
chown root:root /root/.ssh/*

eval `ssh-agent -s` && ssh-add $SSH_KEY

if [ ! -f ./security.yml ]; then
    ./security-setup --enable=false
fi

terraform get
terraform apply -state=$TERRAFORM_STATE_ROOT/terraform.tfstate
ansible-playbook /mi/playbooks/wait-for-hosts.yml --private-key $SSH_KEY
ansible-playbook /mi/mantl.yml --extra-vars=@security.yml --private-key $SSH_KEY
