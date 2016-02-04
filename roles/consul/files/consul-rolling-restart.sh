#!/bin/bash

token=$1

if [ -n "${token}" ]; then
  ccargs="--token=${token}"
fi

# Non-server nodes can be restart immediately with no effect on the quorum
#
if [ $(consul-cli agent-self ${ccargs} | jq -r .Member.Tags.role) == node ]; then
  systemctl restart consul

  exit 0
fi

# Try to acquire a lock on 'locks/consul'
sessionid=$(consul-cli kv-lock ${ccargs} locks/consul)

# Lock acquired. Pause briefly to allow the previous holder to restart
# If it takes longer than five seconds run `systemctl restart consul`
# after releasing the lock then we might cause a quorum outage
sleep 5

# Verify that there is a leader before releasing the lock and restarting
/usr/local/bin/consul-wait-for-leader.sh

# Release the lock
consul-cli kv-unlock ${ccargs} locks/consul --session=${sessionid}

# Restart the service
systemctl restart consul

exit 0
