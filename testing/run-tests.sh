#!/bin/bash
set -ev

# Run tests
## This script is control when testing should be triggered on CI systems

### filter out docfiles
commit_range_minus_docfiles=$(git diff --name-only "$TRAVIS_COMMIT_RANGE" | grep -v -e '^docs/' -e 'md$' -e 'rst$')
if [ -z "$commit_range_minus_docfiles" ]; then
	echo "Skipping build that only has doc changes"
	exit 0
fi

### build master on push, all others only on PRs
if [[ "${TRAVIS_BRANCH}" != "master" && "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
	echo "Skipping push that isn't master"
	exit 0
fi

# skip the build if no secrets are defined for the current provider
if ([[ $TERRAFORM_FILE == "aws.tf" ]] && [[ -z $AWS_SECRET_ACCESS_KEY ]]) || \
   ([[ $TERRAFORM_FILE == "do.tf" ]] && [[ -z $DIGITALOCEAN_TOKEN ]]) || \
   ([[ $TERRAFORM_FILE == "gce.tf" ]] && [[ -z $GOOGLE_CREDENTIALS ]]); then
  exit 0
fi

### if the build wasn't skipped, let's set up
python2 testing/test-health-checks.py
ssh-keygen -N '' -f ~/.ssh/id_rsa && eval "$(ssh-agent)" && ssh-add ~/.ssh/id_rsa
ln -sf "$ANSIBLE_PLAYBOOK" terraform.yml
ln -sf "$TERRAFORM_FILE" terraform.tf
mkdir "$HOME/bin" && export PATH=$PATH:$HOME/bin
export TERRAFORM_VERSION=0.6.8
#### GCE doesn't like . in resource.name, so replace "." with "-"
curl -SL -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -d "$HOME/bin" terraform.zip

### if nothing happened during the setup, let's build
python2 testing/build-cluster.py
