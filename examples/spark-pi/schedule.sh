#!/bin/bash

echo "Please insert your MANTL control node IP address (or domain name)"
read -r MANTL_CONT
echo "Please insert your MANTL admin password:"
read -sr MANTL_PASS
CHRONOS="admin:$MANTL_PASS@$MANTL_CONT/chronos"

curl -k -i -L -X POST -H "Content-type: application/json" "https://$CHRONOS/scheduler/iso8601" -d@"spark-pi.json"
echo #prints a newline

