#! /bin/sh

export GOMAXPROC=$(nproc)
if test -d /var/lib/etcd/member; then
  ETCD_INITIAL_CLUSTER_STATE=existing
  unset ETCD_INITIAL_ADVERTISE_PEER_URLS
  unset ETCD_INITIAL_CLUSTER
else
  ETCD_INITIAL_CLUSTER_STATE=new
fi

export ETCD_INITIAL_CLUSTER_STATE

exec /usr/bin/etcd "$@"
