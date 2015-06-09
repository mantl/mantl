#!/bin/bash
set -e

if [ ! -f ./security.yml ]; then
    ./security-setup --enable=false
fi

cat > wait-for-hosts.yml << EOF
- hosts: all
  gather_facts: no
  tasks:

    - name: wait for ssh to become available
      local_action: wait_for
                    port=22
                    host="{{ ansible_ssh_host | default(inventory_hostname) }}"
                    search_regex=OpenSSH
                    delay=10
EOF

terraform get
terraform apply -state=$TERRAFORM_STATE_ROOT/terraform.tfstate
ansible-playbook wait-for-hosts.yml
ansible-playbook terraform.yml --extra-vars=@security.yml
