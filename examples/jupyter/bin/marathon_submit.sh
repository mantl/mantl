#!/bin/bash

curl -k -i -L -X POST -H "Content-type: application/json" "https://$MARATHON/v2/apps" -d@"$@"
echo #prints a newline

