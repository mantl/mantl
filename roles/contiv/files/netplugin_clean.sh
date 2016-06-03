#!/bin/bash
ovs-vsctl del-br contivVxlanBridge
ovs-vsctl del-br contivVlanBridge
for p in `ifconfig  | grep vport | awk '{print $1}'`; do sudo ip link delete $p type veth; done

