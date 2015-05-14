#!/bin/bash

MAX_SECONDS=60
while /bin/true
do
    curl -X GET -s http://localhost:8500/v1/health/service/marathon?pretty | grep -q "pong" && exit 0 || sleep 1
    [[ "$SECONDS" -ge "$MAX_SECONDS" ]] && exit 1
done

# EOF
