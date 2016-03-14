set -e
./docker_ssh.sh
terraform destroy --force || true
terraform destroy --force
