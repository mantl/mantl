Hi Brian. Here are some notes on Contiv and what I've been trying to do.

Contiv is mostly an application called [https://github.com/contiv/netplugin](netplugin) that sets up networking policies for clusters.

One node (called "netmaster") in the cluster is the master and manages networking policies for all other clusters.

I tried to make ansible task that setup contiv and its dependencies based off of the ones found in the [https://github.com/contiv/demo](demo).

The major dependencies are
- etcd
- docker-flannel
- opencontrail
- kubernetes

I tried to create 3 ansible roles to setup contiv.
- contiv : general install of contiv dependencies
- contiv-master : stuff specific for netmaster
- contiv-node : stuff specific for nodes

I also added a new host called kubemaster that's dedicated to being the netmaster for kubernetes
