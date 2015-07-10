#!/bin/bash

set -e

MASTER_TOKEN="$1"
AGENT_TOKEN="$2"

consul-cli acl-update --token=${MASTER_TOKEN} --name=agent_policy \
    --rule='key::write' \
    --rule='service::write' \
    ${AGENT_TOKEN}
