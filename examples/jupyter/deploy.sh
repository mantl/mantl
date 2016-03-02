#!/bin/bash

echo "Please insert your MANTL control node IP address (or domain name)"
read -r MANTL_CONT
echo "Please instert your MANTL admin password:"
read -sr MANTL_PASS
MARATHON="admin:$MANTL_PASS@$MANTL_CONT/marathon"

curl -k -i -L -X POST -H "Content-type: application/json" "https://$MARATHON/v2/apps" -d@"jupyter.json"
echo #prints a newline

