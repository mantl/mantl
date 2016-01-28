#!/bin/bash
#
# Restart the Consul agents one at a time to avoid losing quorum.

set -x

token=$1

# This will loop forever if the remote consul node
# doesn't come up. Maybe add a timer.
#
function wait_for_upness {
	n=$1

	# Give the remote agent a few seconds to shut down
	# before checking upness
	#
	sleep 5

	while :; do
		status=$(consul-cli agent-members ${ccargs} | jq -r ".[] | select(.Name == \"$n\") | .Status")
		if [ "${status}" == "1" ]; then
			return
		fi
		sleep 5
	done
}

if [ -n "${token}" ]; then
	cargs="-token ${token}"
	ccargs="--token=${token}"
fi

me=$(consul-cli agent-self ${ccargs} | jq -r .Member.Addr)
leader=$(consul-cli status-leader ${ccargs} | cut -f 1 -d ':')

if [ -z "${me}" ]; then
	echo "Not a consul server."
	exit 0
fi

# Not sure if this check should exit as a failure
# or as a success. Failure for now.
#
if [ -z "${leader}" ]; then
	echo "No leader found. Exiting."
	exit 1
fi

# Currently, non-leaders set a watch on a K/V node and restart the agent
# when the node changes. If there is a command executor in place, it can
# be used to restart the agent instead of the watch mechanism.
#
if [ "${me}" != "$leader" ]; then
	# Not the leader. Set a watch on /v1/kv/secure/$me/restart. When that
	# changes, restart consul
	#
	consul-cli kv-watch ${ccargs} secure/${me}/restart >/dev/nul
	if [ $? -ne 0 ]; then
		echo "Error watching restart key"
		exit 1
	fi

	consul-cli kv-delete ${ccargs} secure/${me}/restart

	systemctl restart consul

	exit 0
fi

# Restart any consul client instances first. This is done by sorting
# on the 'role'. 'node' == client and 'consul' == server.
#
for i in $(consul-cli agent-members ${ccargs} | \
		jq -r '.[] | .Name + ":" + .Addr + ":" + .Tags.role' | \
		sort -r -t ':' -k 3); do
	node=$(echo ${i} | cut -f 1 -d ':')
	ip=$(echo ${i} | cut -f 2 -d ':')

	if [ -z "${node}" -o -z "${ip}" ]; then
		echo "Bad return from `consul-cli agent-members`: ${i}"
		exit 1
	fi

	if [ "${ip}" != "${me}" ]; then
		consul-cli kv-write ${ccargs} secure/${ip}/restart restart
		wait_for_upness ${node}
	fi
done

# All restarted except for leader
#
echo "Restarting leader"
systemctl restart consul

exit 0
