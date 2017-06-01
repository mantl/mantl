#!/usr/bin/env python
# This script updates the allowed address pairs in Neutron with the
# 'neutron port-update' command. This is required by Calico in OpenStack,
# otherwise BGP will not be working. We query OpenStack API directly to prevent
# installing any dependencies such as python-neutronclient.
#
# USAGE: script_name arg1 arg2...argN
# arg1 - Calico network, i.e. 192.168.0.0/24
# arg2...argN - VMs MAC addresses
#
# Script exit codes (for Ansible)
# 0 - port has been updated
# 1 - error
# 2 - no update to port [default]

import json
import os
import requests
import sys

def credentials():
    """Retrieves credentials"""

    username = os.environ.get('OS_USERNAME')
    password = os.environ.get('OS_PASSWORD')
    tenant_name = os.environ.get('OS_TENANT_NAME')
    auth_url = os.environ.get('OS_AUTH_URL')

    if not all((username, password, tenant_name, auth_url)):
        sys.stderr.write("ERROR: Unable to get Keystone credentials\n")
        exit(1)

    return {
        'username': username,
        'password': password,
        'tenant_name': tenant_name,
        'auth_url': auth_url
    }

def get_catalog():
    """Get service catalog from Keystone with token and all endpoints"""

    creds = credentials()
    headers = {'Content-Type': 'application/json'}
    payload = {
                "auth":
                  {
                    "tenantName": creds['tenant_name'],
                    "passwordCredentials": {
                                             "username": creds['username'],
                                             "password": creds['password']
                                           }
                  }
              }
    auth_url = creds['auth_url'] + "/tokens"
    r = requests.post(auth_url, headers=headers, data=json.dumps(payload))

    parsed_json = json.loads(r.text)
    if not parsed_json or 'error' in parsed_json:
        sys.stderr.write("ERROR: Unable to get authentication token\n")
        exit(1)

    return parsed_json

def get_token(catalog):
    """Get Keystone authentication token"""

    return catalog['access']['token']['id']

def neutron_public_url(catalog):
    """Get Neutron publicURL"""

    for i in catalog['access']['serviceCatalog']:
        if i['type'] == 'network':
            for endpoint in i['endpoints']:
                return endpoint['publicURL']

def list_ports(token, public_url):
    """List Neutron ports"""

    headers = {'X-Auth-Token': token}
    auth_url = public_url + "v2.0/ports"
    r = requests.get(auth_url, headers=headers)

    if r.text:
        parsed_json = json.loads(r.text)
        return parsed_json['ports']
    else:
        sys.stderr.write("ERROR: Unable to retrieve Neutron ports list\n")
        exit(1)

def update_port(token, public_url, port_id, mac_address, calico_network):
    """Update Neutron port with the allowed address pairs"""

    headers = {'Content-Type': 'application/json', 'X-Auth-Token': token}
    payload = {
                "port": {
                          "allowed_address_pairs": [
                             {
                               "ip_address": calico_network,
                               "mac_address": mac_address
                             }
                          ]
                        }
              }
    auth_url = public_url + "v2.0/ports/" + port_id
    r = requests.put(auth_url, headers=headers, data=json.dumps(payload))

    parsed_json = json.loads(r.text)
    if r.status_code != 200 or 'NeutronError' in parsed_json:
        sys.stderr.write("ERROR: Unable to update port: %s\n" % parsed_json['NeutronError'])
        exit(1)
    else:
        return r.status_code

if __name__ == "__main__":

    if len(sys.argv) < 3:
        sys.stderr.write("ERROR: Please run script with the correct arguments\n")
        exit(1)

    calico_network = sys.argv[1]
    vms_mac_addresses = sys.argv[2:]

    catalog = get_catalog()
    token = get_token(catalog)
    public_url = neutron_public_url(catalog)
    ports = list_ports(token, public_url)

    exit_code = 0 # no update to port

    for port in ports:
        port_id = port['id']
        mac_address = port['mac_address']
        if mac_address in vms_mac_addresses and not port['allowed_address_pairs']:
            status_code = update_port(token, public_url, port_id, mac_address, calico_network)
            if status_code == 200:
                exit_code = 2 # port has been updated

    exit(exit_code)
