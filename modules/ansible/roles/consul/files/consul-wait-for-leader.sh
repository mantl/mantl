#!/bin/bash

token=$1

if [ -n "${token}" ]; then
  ccargs="--token=${token}"
fi

max_wait=30

while :; do
  if [[ $(consul-cli status-leader ${ccargs}) =~ [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]* ]]; then
    exit 0
  fi

  if [ $SECONDS -gt $max_wait ]; then
    echo "No Consul leader elected in 30 seconds"
    exit 1
  fi

  sleep 5
done
