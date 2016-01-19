#!/bin/bash

max_wait=30

while :; do
  if [[ $(curl -s localhost:8500/v1/status/leader) =~ \"[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]*\" ]]; then
    exit 0
  fi

  if [ $SECONDS -gt $max_wait ]; then
    echo "No Consul leader elected in 30 seconds"
    exit 1
  fi

  sleep 5
done
