set -e
./docker_ssh.sh
python2 testing/build-cluster.py
