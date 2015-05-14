#!/bin/bash
set -ex

# Set the root password to an impossible value
usermod -p ! root

# EOF
