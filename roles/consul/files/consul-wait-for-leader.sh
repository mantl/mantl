#!/bin/bash

max_wait=30
wait_time=0

while :; do
  if [ "`curl -s localhost:8500/v1/status/leader`" != '""' ]; then
    exit 0
  fi

  wait_time+=5
  if [ $wait_time -gt $max_wait ]; then
    echo "No Consul leader elected in 30 seconds"
    exit 1
  fi

  sleep 5
done
