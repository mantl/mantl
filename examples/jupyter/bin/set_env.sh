#!/bin/bash

echo "Please insert your Mantl control node URL"
read -r MANTL_CONT
echo "Please instert your Mantl password:"
read -sr MANTL_PASS
export MARATHON="admin:$MANTL_PASS@$MANTL_CONT/marathon"
export CHRONOS="admin:$MANTL_PASS@$MANTL_CONT/chronos"

