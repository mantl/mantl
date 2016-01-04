#!/bin/sh -e
set -x

MNT="$1"

while true; do
  if ! mountpoint -q "${MNT}"; then
    mount "${MNT}" && ls -la ${MNT} || echo "Mounting ${MNT} failed, retrying..."
  fi
  sleep 10
done
