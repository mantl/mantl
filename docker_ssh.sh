set -e

python2 -c "import docker_setup; docker_setup.link_or_generate_ssh_keys()"
eval $(ssh-agent)
ssh-add
