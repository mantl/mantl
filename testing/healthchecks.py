#!/usr/bin/env python2
from __future__ import print_function
import sys
import json
import base64
from time import sleep
import urllib2
import ssl
import subprocess

def get_credentials():
    """ Get consul api password from security.yml """
    # TODO: is this the correct YAML key for the Consul API password?
    yaml_key = "nginx_admin_password:"
    try:
        with open('security.yml') as f:
            for line in f:
                if yaml_key in line:
                    # credentials are the whole string after the key
                    password = line[len(yaml_key):].strip()
                    # only grab what we need
                    return "admin:"+password
    except IOError:
        # Returning "" ensures that unit tests will run network code, rather
        # than just failing because security.yml isn't present.
        return ""

def get_hosts_from_json(json_str, role="control"):
    """ Get a list of IP addresses of hosts with a certain role from a JSON
    string """
    ips = []
    json_dic = json.loads(json_str)
    host_data = json_dic["_meta"]["hostvars"]
    for key, dic in host_data.iteritems():
        if dic.get("role", "").lower() == role:
            ips.append(dic["public_ipv4"])
    return ips

def get_hosts_from_dynamic_inventory(cmd, role="control"):
    """ Get a list of IP addresses of control hosts from terraform.py """
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    rc = proc.wait()
    if rc != 0:
        print("terraform.py exited with ", rc)
        return []
    else:
        return get_hosts_from_json(proc.stdout.read())

def node_health_check(node_address):
    """ Return a boolean: if a node passes all of its health checks """

    # Create a context that doesn't validate SSL certificates, since Mantl's
    # are self-signed.
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    url = "https://" + node_address + "/consul/v1/health/state/any"
    request = urllib2.Request(url)
    auth = b'Basic ' + base64.b64encode(get_credentials())
    request.add_header("Authorization", auth)

    try:
        f = urllib2.urlopen(request, None, 30, context=ctx)
        health_checks = json.loads(f.read().decode('utf8'))
        for check in health_checks:
            if check['Status'] != "passing":
                print(check['Name'] + ": " + check['Status'])
                return False
    except Exception as e:
        print("Check at IP ", node_address, " exited with this error\n", e)
        return False

    return True

def cluster_health_check(ip_addresses):
    """ Return an integer representing how many nodes failed """
    failed = 0
    for ip in ip_addresses:
        passed = node_health_check(ip)
        print("Node ", ip, " ", "passed" if passed else "failed")
        failed += 0 if passed else 1
    return failed

if __name__ == "__main__":
    print("Waiting for cluster to finalize init before starting health checks")
    sleep(60*2)  # two minutes

    # Get IP addresses of hosts from a dynamic inventory script
    cmd = ["python2", "plugins/inventory/terraform.py", "--list"]
    address_list = get_hosts_from_dynamic_inventory(cmd)

    if len(address_list) == 0:
        print("terraform.py reported no control hosts.")
        sys.exit(1)

    failed = cluster_health_check(address_list)
    sys.exit(0 if failed == 0 else 1)
