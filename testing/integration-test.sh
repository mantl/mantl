#!/usr/bin/env bash

# This integration test assumes that ./terraform.yml and ./terraform.tf are
# already in place

exit_code=0 # passing until proven failed
retry_attempts=2

# Retry evaluating $1, $retry_attempts times.
function retry_command() {
  for i in $(seq $retry_attempts); do
    printf "CMD: %s\tTRY: %s" "$1" "$i"
    if eval "$1"; then
      break
    else
      exit_code=1
    fi
  done
}

# Evaluate $1 only if $exit_code == 0. Otherwise, skip it.
function skip_if_failed() {
  if [ $exit_code -eq 0 ]; then
    printf "CMD: %s" "$1"
    if ! eval "$1"; then
      exit_code=1
      printf "CMD FAILED, SETTING EXIT CODE TO %s" "$exit_code"
      return
    else
      echo "CMD SUCCESS, ON TO NEXT CMD"
      return
    fi
  else
    printf "CMD \"%s\" ABORTED DUE TO PREVIOUS FAILURE" "$1"
  fi
}

echo "Running security-setup without TTY"; ./security-setup < /dev/null

skip_if_failed "terraform get"
skip_if_failed "terraform apply"
retry_command "ansible-playbook playbooks/wait-for-hosts.yml --private-key ~/.ssh/id_rsa"
skip_if_failed "ansible-playbook -e 'serial=0' playbooks/upgrade-packages.yml"
skip_if_failed "ansible-playbook terraform.yml --extra-vars=@security.yml --private-key ~/.ssh/id_rsa"
plugins/inventory/terraform.py --hostfile \
  | awk '/control/ {print $1}' \
  | xargs -I sh -c 'skip_if_failed "testing/health-checks.py {}"'

# Print debugging information if any tasks failed
if [[ $exit_code -ne 0 ]]; then
  ansible-playbook testing/ci-debug.yml -e @security.yml \
    --private-key ~/.ssh/id_rsa
fi

# must retry for terraform bugs
retry_command "terraform destroy -force"

rm security.yml terraform.tf terraform.yml # convenient for local builds

exit $exit_code
