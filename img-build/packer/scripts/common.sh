#!/bin/bash
set -ex

yum makecache -y
yum install -y httpd-tools
yum upgrade -y httpd-tools

# EOF
