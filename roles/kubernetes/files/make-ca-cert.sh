#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

# Caller should set in the ev:
# MASTER_IP - this may be an ip or things like "_use_gce_external_ip_"
# DNS_DOMAIN - which will be passed to minions in --cluster_domain
# SERVICE_CLUSTER_IP_RANGE - where all service IPs are allocated
# MASTER_NAME - I'm not sure what it is...

# Also the following will be respected
# CERT_DIR - where to place the finished certs
# CERT_GROUP - who the group owner of the cert files should be

service_range="${SERVICE_CLUSTER_IP_RANGE:="10.0.0.0/16"}"
dns_domain="${DNS_DOMAIN:="cluster.local"}"
cert_dir="${CERT_DIR:-"/tmp/certs"}"
cert_group="${CERT_GROUP:="kube"}"
masters="${MASTERS}"

# The following certificate pairs are created:
#
#  - ca (the cluster's certificate authority)
#  - server
#  - kubelet
#  - kubecfg (for kubectl)

tmpdir=$(mktemp -d -t kubernetes_cacert.XXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT
cd "${tmpdir}"

# Calculate the first ip address in the service range
octects=($(echo "${service_range}" | sed -e 's|/.*||' -e 's/\./ /g'))
((octects[3]+=1))
service_ip=$(echo "${octects[*]}" | sed 's/ /./g')

# Determine appropriete subject alt names
sans="IP:${service_ip},IP:127.0.0.1,DNS:localhost,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.${dns_domain}"
hosts=$(for host in ${masters}; do echo DNS:${host}; done|tr [[:space:]] ,)
sans="$sans,${hosts%?}"

curl -L -O https://github.com/OpenVPN/easy-rsa/releases/download/3.0.0/EasyRSA-3.0.0.tgz > /dev/null 2>&1
tar xzf EasyRSA-3.0.0.tgz > /dev/null
cd EasyRSA-3.0.0

(./easyrsa init-pki > /dev/null 2>&1
 ./easyrsa --batch "--req-cn=kubernetes@$(date +%s)" build-ca nopass > /dev/null 2>&1
 ./easyrsa --subject-alt-name="${sans}" build-server-full server nopass > /dev/null 2>&1
 ./easyrsa build-client-full kubelet nopass > /dev/null 2>&1
 ./easyrsa build-client-full kubecfg nopass > /dev/null 2>&1) || {
 # If there was an error in the subshell, just die.
 # TODO(roberthbailey): add better error handling here
 echo "=== Failed to generate certificates: Aborting ==="
 exit 2
 }

mkdir -p "$cert_dir"

cp -p pki/ca.crt "${cert_dir}/ca.crt"
cp -p pki/issued/server.crt "${cert_dir}/server.crt"
cp -p pki/private/server.key "${cert_dir}/server.key"
cp -p pki/issued/kubecfg.crt "${cert_dir}/kubecfg.crt"
cp -p pki/private/kubecfg.key "${cert_dir}/kubecfg.key"
cp -p pki/issued/kubelet.crt "${cert_dir}/kubelet.crt"
cp -p pki/private/kubelet.key "${cert_dir}/kubelet.key"

CERTS=("ca.crt" "server.key" "server.crt" "kubelet.key" "kubelet.crt" "kubecfg.key" "kubecfg.crt")
for cert in "${CERTS[@]}"; do
#   chgrp "${cert_group}" "${cert_dir}/${cert}"
  chmod 666 "${cert_dir}/${cert}"
done
