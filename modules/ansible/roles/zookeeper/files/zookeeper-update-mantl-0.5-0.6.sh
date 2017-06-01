#!/bin/sh -e
set -x
set -o pipefail

ZKUSER=${1:-zookeeper}

if test -d /var/lib/zookeeper/version-2; then
    # Already upgraded, or fresh 0.6.x setup
    exit 0
fi

if systemctl show zookeeper | grep -q docker >/dev/null; then
    systemctl disable zookeeper || :  # not fail here
    systemctl stop zookeeper
    rm -f /usr/lib/systemd/system/zookeeper.service
    systemctl daemon-reload
fi

if test -d /var/log/zookeeper/version-2; then
    mkdir -p /var/lib/zookeeper
    mv /var/log/zookeeper/version-2 /var/lib/zookeeper/version-2
    chown -R ${ZKUSER} /var/lib/zookeeper/version-2
fi
