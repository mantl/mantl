#!/usr/bin/env bash

## This integration test assumes that ./terraform.yml and ./terraform.tf are already in place

export EXIT_CODE=0 # passing until proven failed
RETRY_ATTEMPTS=2

function retry_command() {
	for i in `seq 1 $RETRY_ATTEMPTS`
	do
		echo -e "CMD: $1\tTRY: $i"
		eval $1
		RETRY=$?
		if [ $RETRY -eq 0 ]
		then
			break
		fi
	done
	if [ $RETRY -ne 0 ]
	then
		EXIT_CODE=1
	fi
}

function skip_if_failed() {
	if [ $EXIT_CODE -eq 0 ]
	then
		echo -e "CMD: $1"
		eval $1
		if [ $? -ne 0 ]
		then
			EXIT_CODE=1
			echo "CMD FAILED, SETTING EXIT CODE TO $EXIT_CODE"
			return
		else
			echo "CMD SUCCESS, ON TO NEXT CMD"
			return
		fi
	else
		echo -e "CMD \"$1\" ABORTED DUE TO PREVIOUS FAILURE"
	fi

}

echo "Running security-setup without TTY"; ./security-setup < /dev/null

skip_if_failed "terraform get"
skip_if_failed "terraform apply"
retry_command "ansible-playbook playbooks/wait-for-hosts.yml --private-key ~/.ssh/id_rsa"
skip_if_failed "ansible-playbook -e 'serial=0' playbooks/upgrade-packages.yml"
skip_if_failed "ansible-playbook terraform.yml --extra-vars=@security.yml --private-key ~/.ssh/id_rsa"
skip_if_failed "testing/health-checks.py $(plugins/inventory/terraform.py --hostfile | awk '/control/ {print $1}')"

# must retry for terraform bugs
retry_command "terraform destroy -force"

rm security.yml terraform.tf terraform.yml # convenient for local builds

exit $EXIT_CODE
