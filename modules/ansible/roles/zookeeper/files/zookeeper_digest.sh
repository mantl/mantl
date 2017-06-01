#! /bin/bash
set -e
set -o pipefail

# ZK_ENV script contain bashizms, so we need bash, not sh
ZOOBINDIR="/opt/mesosphere/zookeeper/bin"
ZK_ENV="$ZOOBINDIR/zkEnv.sh"

if test $# -ne 1; then
  echo "Usage: $0 user:password" >&2
  exit 1
fi


if ! test -f $ZK_ENV; then
  echo "mesosphere-zookeeper rpm not installed" >&2
  exit 1
fi

. $ZK_ENV

java -cp "$CLASSPATH" org.apache.zookeeper.server.auth.DigestAuthenticationProvider "$1" | awk -F '->' '{print $2}'
