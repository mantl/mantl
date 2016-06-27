#!/usr/bin/env bash

# this script is to emulate the CI testing suite locally
# because the meat of the code is executed in a docker container
# the main job of this script is to call docker run with the proper config
#
# Examples:
# ./testing/local.sh ci-setup aws
# ./testing/local.sh ci-build gce
# ./testing/local.sh ci-destroy do
# ./testing/local.sh sh


if [ "$#" -lt 1 ]; then
	echo -e "USAGE: testing/local.sh CMD PROVIDER\te.g. testing/local.sh build aws\ntesting/local.sh sh (to interact with container)"
	exit 1
fi

export TF_VAR_build_number="$(whoami)-local"
export TRAVIS_COMMIT_RANGE="$(git rev-parse master)...$(git rev-parse HEAD)"
export CI_HEAD_COMMIT=$(git rev-list -n 1 --no-merges --branches="$(git rev-parse --abbrev-ref HEAD)" master...HEAD)
export DOCKER_ARGS='--rm -i -a stdout -a stderr -e TF_VAR_build_number -e CI_HEAD_COMMIT -e TRAVIS_COMMIT_RANGE -e TRAVIS_REPO_SLUG=CiscoCloud/mantl -e TRAVIS_BRANCH=master -e TRAVIS_PULL_REQUEST=1 -e TERRAFORM_FILE -e DOCKER_SECRETS'
export DOCKER_IMAGE=sehqlr/mantl:testing

case $1 in
"sh")
	docker run $DOCKER_ARGS -a stdin -t -v $(pwd)/testing:/local -v $(pwd):/mantl $DOCKER_SECRETS $DOCKER_IMAGE "sh"
	;;
*)
	export CMD=$1
	shift
	;;
esac

export PROVIDER=$(echo "$1" | tr '[:upper:]' '[:lower:]')


# You will likely need to export env vars to make this work
case $PROVIDER in
"aws")
	export TERRAFORM_FILE=testing/aws.tf
	export DOCKER_SECRETS='-e AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID'
	;;
"do")
	export TERRAFORM_FILE=testing/do.tf
	export DOCKER_SECRETS='-e DIGITALOCEAN_TOKEN'
	;;
"gce")
	export TERRAFORM_FILE=testing/gce.tf
	export DOCKER_SECRETS='-e GOOGLE_CREDENTIALS'
	;;
esac

echo "python2 docker.py $CMD"

docker run $DOCKER_ARGS -v $(pwd)/testing:/local -v $(pwd):/mantl $DOCKER_SECRETS $DOCKER_IMAGE "env"
docker run $DOCKER_ARGS -v $(pwd)/testing:/local -v $(pwd):/mantl $DOCKER_SECRETS $DOCKER_IMAGE "python2 docker.py $CMD"
