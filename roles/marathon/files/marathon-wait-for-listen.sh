#!/bin/bash

MAX_SECONDS=60
while /bin/true
do
    [[ "$(curl -X GET -m 5 -s http://localhost:18080/ping)" == "pong" ]] && exit 0 || sleep 1
    [[ "$SECONDS" -ge "$MAX_SECONDS" ]] && exit 1
done

# EOF
