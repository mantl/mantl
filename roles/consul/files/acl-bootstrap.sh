#!/bin/bash
set -e

MASTER_TOKEN="$1"
AGENT_TOKEN="$2"

create_acl() {
    curl -X PUT "http://localhost:8500/v1/acl/create?token=$MASTER_TOKEN" \
        -d '{"Name": "agent_policy", "Type": "client", "Rules": "service \"\" {policy = \"write\"}"}'
}

if [[ -z "$AGENT_TOKEN" ]]; then
    create_acl
elif [[ "$(curl -s http://localhost:8500/v1/acl/info/$AGENT_TOKEN?token=$MASTER_TOKEN)" == "null" ]]; then
    create_acl
else
    echo "{ \"ID\":\"$AGENT_TOKEN\" }"
fi

# EOF
