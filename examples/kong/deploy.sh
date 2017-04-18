#!/bin/bash
set -e

# The IP address of one of your control nodes
# You can find this by running `./plugins/inventory/terraform.py --hostfile`
ip=0.0.0.0
# User for Marathon server (default: admin)"
username=youruser
# Password for Marathon server (see 'nginx_admin_password' in security.yml)
password=yourpass

# Search the Consul services record to see if a service is available yet
service_is_available() {
  curl -X GET -sku "$username:$password" \
       "https://$ip/consul/v1/catalog/services" \
      | grep -q "$1"
}

app_is_healthy() {
    curl -X GET -sku "$username:$password" \
         "https://$ip/marathon/v2/apps$1" \
        | grep -q "\"tasksUnhealthy\":0"
}

# Install the Cassandra mesos framework via mantl-api
# Available (by default) at: cassandra-kong-node.service.consul:9042
# By default, this will be a single node cassandra cluster. You can adjust the
# settings in the cassandra.json file in this directory to configure the number
# of cassandra nodes.
# Marathon ID: /cassandra/kong
if ! service_is_available cassandra-kong-node; then
  echo "Installing Cassandra..." ; sleep 2
  curl -X POST -sku "$username:$password" \
               -H "Content-Type: application/json" \
               -d @cassandra.json \
               "https://$ip/api/1/install"
fi
echo; echo

# Wait for Cassandra service to become available in Consul
printf "Waiting for Cassandra to become available..." ; sleep 2
while ! service_is_available cassandra-kong-node; do
  printf "%s" "." ; sleep 2
done
echo; echo

printf "Waiting for Cassandra to become healthy..."; sleep 2
while ! app_is_healthy /cassandra/kong; do
  printf "%s" "." ; sleep 5
done
echo; echo

echo "Installing Kong..." ; sleep 2
# Post the kong.json app description to Marathon
curl -X POST -sku "$username:$password" \
             -H "Content-Type: application/json" \
             -d @kong.json \
             "https://$ip/marathon/v2/apps"
echo; echo
