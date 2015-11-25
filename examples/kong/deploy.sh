#!/bin/bash
set -e

# The IP address of one of your control nodes
# You can find this by running `./plugins/inventory/terraform.py --hostfile`
ip=0.0.0.0
# User for Marathon server (default: admin)"
username=youruser
# Password for Marathon server (see 'nginx_admin_password' in security.yml)
password=yourpass

# Run an Ansible playbook that just deploys kong.yml configuration to all nodes
# at /etc/kong/kong.yml
ansible-playbook main.yml -e @../../security.yml \
                          -e "ansible_python_interpreter=$(which python2)" \
                          -i ../../plugins/inventory/terraform.py

# Search the Consul services record to see if a service is available yet
service_is_available() {
  curl -X GET -sku "$username:$password" \
       "https://$ip:8500/v1/catalog/services" \
       | grep -q "$1"
}

# Install the Cassandra mesos framework via mantl-api
# Available at: cassandra-mantl-node.service.consul:9042
# Marathon ID: /cassandra/mantl
if ! service_is_available cassandra-mantl-node; then
  curl -X POST -sku "$username:$password" \
               -H "Content-Type: application/json" \
               -d '{"name": "cassandra"}' \
               "https://$ip/api/1/packages"
fi

# Wait for Cassandra service to become available in Consul
echo "Waiting for Cassandra to become available..." ; sleep 2
while ! service_is_available cassandra-mantl-node; do
  printf "%s" "." ; sleep 2
done

# Post the kong.json app description to Marathon
curl -X POST -sku "$username:$password" \
             -H "Content-Type: application/json" \
             -d @kong.json \
             "https://$ip/marathon/v2/apps"
