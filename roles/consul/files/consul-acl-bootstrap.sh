#!/bin/bash

set -e

MASTER_TOKEN="$1"
AGENT_TOKEN="$2"

curl -X PUT "http://localhost:8500/v1/acl/create?token=$MASTER_TOKEN" \
    -d "{ \"ID\": \"$AGENT_TOKEN\", \"Name\": \"agent_policy\", \"Type\": \"client\", \"Rules\": \"service \\\"\\\" { policy = \\\"write\\\"}\"}"
