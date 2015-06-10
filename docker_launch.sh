#!/bin/bash
set -e

if [ ! -f ./security.yml ]; then
    ./security-setup --enable=false
fi

terraform get
terraform apply -state=$TERRAFORM_STATE_ROOT/terraform.tfstate
ansible-playbook /mi/playbooks/wait-for-hosts.yml
ansible-playbook /mi/terraform.yml --extra-vars=@security.yml
