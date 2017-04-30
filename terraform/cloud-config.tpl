#!/bin/bash
ln -sf /etc/localtime /etc/timezones/${timezone}
curl -SLo /etc/yum.repos.d/mantl.repo ${repo_url}
yum update -y
yum install -y distributive
