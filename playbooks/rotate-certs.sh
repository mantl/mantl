#!/bin/bash
set -e

#### Rotate TLS certs with vault

# Log to stdout and file
echo "" > /tmp/rotate.log
chmod 0600 /tmp/rotate.log
log() {
  printf "[%s] %s\n" "$1" "$2"
  printf "[%s] %s\n" "$1" "$2" >> "/tmp/rotate.log"
  if [[ $1 == "ERR" ]]; then exit 1; fi
}

log INFO "Beginning cert rotation..."
log INFO "Parsing options..."

# Defaults
common_name=$(hostname)
ttl=8760h
lock_path=rotate-certs

original_options=$*
OPTS=$(getopt -n rotate-certs -l common-name:,alt-names:,ip-sans:,ttl:,lock-path:,acl-token:,role:,vault-addr:,vault-cacert:,vault-token: -- "$0" "$@")
if [ $? -ne 0 ]; then
  log ERR "Error parsing options."
fi
eval set -- "${OPTS}"

max=50
while :; do
  if [[ $max -le 0 ]]; then
    log DEBUG "Options were $original_options"
    log ERR "Infinite loop detected while parsing options!"
  fi
  max=$((max-1))

  case "$1" in
    --common-name)  common_name="$2"; shift 2;;
    --alt-names)  alt_names="$2"; shift 2;;
    --ip-sans)  ip_sans="$2"; shift 2;;
    --ttl)  ttl="$2"; shift 2;;
    --lock-path)  lock_path="$2"; shift 2;;
    --acl-token)  acl_token="$2"; shift 2;;
    --role)  role="$2"; shift 2;;
    --vault-addr)  vault_addr="$2"; shift 2;;
    --vault-cacert)  vault_cacert="$2"; shift 2;;
    --vault-token)  vault_token="$2"; shift 2;;
    --)  shift; break;;
  esac
done

log INFO "Validating options..."

# Required
[[ -z ${alt_names} ]] && log ERR "--alt-names must be provided"
[[ -z ${ip_sans} ]] && log ERR "--ip-sans must be provided"
[[ -z ${acl_token} ]] && log ERR "--acl-token must be provided"
[[ -z ${role} ]] && log ERR "--role must be provided"

# Environmental
if [[ -z ${vault_addr} ]]; then
  if [[ -z $VAULT_ADDR ]]; then
    vault_addr=https://vaul.service.consul:8200
    log INFO "--vault-addr and VAULT_ADDR not provided, using ${vault_addr}"
  else
    log INFO "--vault-addr not provided, using VAULT_ADDR environment variable"
    vault_addr=$VAULT_ADDR
  fi
fi

if [[ -z ${vault_cacert} ]]; then
  if [[ -z $VAULT_CACERT ]]; then
    log INFO "--vault-cacert and VAULT_CACERT not provided, none will be used"
  else
    log INFO "--vault-cacert not provided, using VAULT_CACERT environment variable"
    vault_cacert=$VAULT_CACERT
  fi
fi

if [[ -z ${vault_token} ]]; then
  if [[ -z $VAULT_TOKEN ]]; then
    log ERR "--vault-token or VAULT_TOKEN must be provided"
  else
    log INFO "--vault-token not provided, using VAULT_TOKEN environment variable"
    vault_token=$VAULT_TOKEN
  fi
fi

log INFO "Obtaining Consul lock..."
session_id=$(consul-cli kv-lock --behavior=release --ttl=10m --lock-delay=1m --token="${acl_token}" "${lock_path}")
log INFO "Got Consul lock!"

consul maint -enable -reason "rotating TLS certificates" > /dev/null

log INFO "Getting certificate from Vault..."

json=$(printf '{"common_name":"%s","alt_names":"%s","ip_sans":"%s","ttl":"%s"}' \
              "${common_name}" "${alt_names}" "${ip_sans}" "${ttl}")

# If it is restarting on a control node, Vault might be temporarily sealed
curl_output='{"errors":["Vault is sealed"]}'
max=60
while [[ $curl_output == '{"errors":["Vault is sealed"]}' ]]; do
  curl_output=$(curl -LsS -X POST \
                     --tlsv1.2 \
                     --cacert "${vault_cacert}" \
                     --cert /etc/pki/mantl/cert \
                     --key /etc/pki/mantl/key \
                     --connect-timeout 10 \
                     --max-time 20 \
                     -H "X-Vault-Token: ${vault_token}" \
                     -H "Content-Type: application/json" \
                     -d "$json" \
                     "${vault_addr}/v1/pki/issue/cert-rotation")

  sleep 2
  max=$((max-1))
  if [[ $max -le 0 ]]; then
    log ERR "Vault was sealed for too long"
  fi
done

[[ $curl_output == *error* ]] && log ERR "$curl_output"

log INFO "Parsing Vault output..."

# -Mr means don't use color, don't escape newlines, and don't quote output
certificate=$(printf "%s" "$curl_output" | jq -Mr '.data.certificate')
private_key=$(printf "%s" "$curl_output" | jq -Mr '.data.private_key')
ca_cert=$(printf "%s" "$curl_output" | jq -Mr '.data.issuing_ca')

log INFO "Writing certs..."

printf "%s" "$certificate" > /etc/pki/mantl/cert
printf "%s" "$private_key" > /etc/pki/mantl/key

# The CA cert needs to go a couple of places. This might not be necessary, but is
# present just in case the user uploaded a new CA cert to Vault.
for f in CA/ca.cert ca-trust/source/cacert.pem ca-trust/source/anchors/cacert.pem; do
  printf "%s" "$ca_cert" > "/etc/pki/$f"
  # Sanity checking - each CA cert must be valid before overwriting another one
  openssl verify -CAfile "/etc/pki/$f" /etc/pki/mantl/cert
done

log INFO "Reloading services..."

services=("consul" "nginx-consul")
case "$role" in
  worker) services=( ${services[@]} "docker") ;;
  control) services=( ${services[@]} "docker" "kubelet" "nginx-mantlui" "marathon" "vault") ;;
  edge) services=( ${services[@]} "traefik") ;;
  kubeworker) services=( ${services[@]} "docker" "kubelet") ;;
  *) log ERR "$(printf "Unsupported role '%s'\n" "$role")" ;;
esac

for service in "${services[@]}"; do
  # Traefik doesn't properly load new certs on reload, just restart.
  if [[ service == "traefik" ]]; then
    sudo systemctl restart traefik
  else
    log INFO "$(printf "Reloading service '%s'\n" "$service")"
    if ! sudo systemctl reload "${service}"; then
      log INFO "$(printf "Service '%s' couldn't be reloaded, restarting...\n" "$service")"
      sudo systemctl restart "${service}"
    fi
  fi
done

## Clean up

log INFO "Unlocking..."
consul-cli kv-unlock --session="${session_id}" --token="${acl_token}" "${lock_path}"

log INFO "Disabling Consul maintenance mode..."
consul maint -disable

log INFO "Done!"
