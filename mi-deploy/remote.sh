#!/bin/bash

########## Global variables: Customize these for your own use case!
# SSH configuration
username=user
remote_ip=192.168.0.1
ssh_port=2222
# Other settings
remote_dir=/home/$username/mi-deploy
platform=openstack
branch=master
repo_url=https://github.com/CiscoCloud/microservices-infrastructure
# Only fill this in if you have a file that needs to be sourced prior to running
auth_data=""

########## Main logic: Leave this alone!
go build .
# Copy this folder over
dest_with_dir=$username@$remote_ip:$remote_dir
rsync -avz -e "ssh -p 2222" --exclude="deployments/" . "$dest_with_dir" > /dev/null
# Execute the desired command on the remote machine, then drop into a shell
ssh_script="$(cat <<EOF
  cd $remote_dir
  [ -n "$auth_data" ] && source $auth_data
  ./mi-deploy deploy -p $platform -b $branch -u $repo_url
  bash
EOF
)"

# shellcheck disable=SC2029
ssh -t -t -p "$ssh_port" "$remote_ip" "$ssh_script"
