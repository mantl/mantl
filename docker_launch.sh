#!/bin/sh
set -e

if [ -z "$MANTL_PROVIDER" ]; then
	echo "mantl.readthedocs.org for provider"
	exit 1
fi

# SSH
if [ ! -f "$SSH_KEY" ]; then
	ssh-keygen -N '' -f $SSH_KEY
else
	cp $MANTL_CONFIG_DIR/$(basename $SSH_KEY) $(dirname $SSH_KEY)
fi
eval $(ssh-agent) && ssh-add $SSH_KEY

# SECURITY.YML
if [ ! -f $MANTL_CONFIG_DIR/security.yml ]; then
	./security-setup --enable=false
else
	cp /local/security.yml security.yml
fi

# MANTL.YML
if [ ! -f $MANTL_CONFIG_DIR/mantl.yml ]; then
	cp sample.yml mantl.yml
else
	cp $MANTL_CONFIG_DIR/mantl.yml mantl.yml
fi

# TERRAFORM FILES
if [ "$(find $MANTL_CONFIG_DIR -name '*.tf')" == "" ]; then
	cp /mantl/terraform/"$MANTL_PROVIDER".sample.tf mantl.tf
else
	cp /local/*.tf /mantl/
fi

terraform get
terraform apply -state=$TERRAFORM_STATE
ansible-playbook /mantl/playbooks/wait-for-hosts.yml --private-key $SSH_KEY
ansible-playbook mantl.yml -e @"$MANTL_CONFIG_DIR/security.yml" --private-key $SSH_KEY
