#!/bin/bash

[[ "$(echo ruok | nc "$HOSTNAME" 2181 2>/dev/null)" == "imok" ]] && exit 0 || exit 1
