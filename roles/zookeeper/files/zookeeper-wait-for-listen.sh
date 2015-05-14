#!/bin/bash

MAX_SECONDS=60
while /bin/true
do
    [[ "$(echo ruok | nc "$HOSTNAME" 2181 2>/dev/null)" == "imok" ]] && exit 0 || sleep 1
    [[ "$SECONDS" -ge "$MAX_SECONDS" ]] && exit 1
done

# EOF
