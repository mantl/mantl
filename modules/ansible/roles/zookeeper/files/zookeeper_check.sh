#!/bin/bash

[[ -n "$1" ]] && host=$1 || host=$HOSTNAME

[[ "$(echo ruok | nc "$host" 2181 2>/dev/null)" == "imok" ]] && exit 0 || exit 1
