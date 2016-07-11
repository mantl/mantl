#!/usr/bin/env python2
from __future__ import print_function
import base64
import json
import logging
import socket
import ssl
import subprocess
import sys
import time
import urllib2


def get_credentials():
    """ Get consul api password from security.yml """
    # TODO: Should we just add pyyaml as a dependency?
    yaml_key = "nginx_admin_password:"
    try:
        with open('security.yml', 'r') as f:
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
    """ Get a list of (hostname, ip) pairs with a certain role from a JSON
    string """
    ips = []
    host_data = json.loads(json_str)["_meta"]["hostvars"]
    for key, dic in host_data.iteritems():
        if dic.get("role", "").lower() == role:
            ips.append((key, dic["public_ipv4"]))
    return ips


def get_hosts_from_dynamic_inventory(cmd, role="control"):
    """ Get a list of IP addresses of control hosts from terraform.py """
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    rc = proc.wait()
    if rc != 0:
        logging.error("terraform.py exited with ", rc)
        return []
    else:
        return get_hosts_from_json(proc.stdout.read())


def failing_checks(node_address, timeout=30):
    """ Returns a list of failing checks. """

    # Verify TLS certs using the generated CA
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.load_verify_locations(cafile="ssl/cacert.pem")
    ctx.verify_mode = ssl.CERT_REQUIRED

    url = "https://{}:8500/v1/health/state/any".format(node_address)
    request = urllib2.Request(url)
    auth = b'Basic ' + base64.b64encode(get_credentials())
    request.add_header("Authorization", auth)

    f = urllib2.urlopen(request, None, timeout, context=ctx)
    checks = json.loads(f.read().decode('utf8'))

    return [c for c in checks if c.get("Status", "").lower() != "passing"]

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    logging.info("Getting hosts")
    # Get IP addresses of hosts from a dynamic inventory script
    cmd = ["python2", "plugins/inventory/terraform.py", "--list"]
    hosts = get_hosts_from_dynamic_inventory(cmd)

    if len(hosts) == 0:
        logging.error("terraform.py reported no control hosts.")
        sys.exit(1)

    # If it's been less than five minutes, accept failures.
    logging.info("Beginning health checks")
    began = time.time()
    failed = True
    while time.time() - began < 300 and failed:
        timeout = 5
        for hostname, ip in hosts:
            try:
                failed = failing_checks(ip, timeout=timeout)
                if not failed:
                    logging.info("All Consul health checks are passing.")
                    sys.exit(0)
                else:
                    for check in failed:
                        name = check.get("Name", "<unknown>")
                        status = check.get("Status", "<unknown>")
                        output = check.get("Output", "<unknown>")
                        logging.warn("Check '{}' failing with status '{}' and output: {}".format(name, status, output))

            except socket.timeout as e:
                logging.warn("Network timeout: {}".format(e))
                timeout += 5

            except ValueError as e:
                logging.warn("Error decoding JSON: {}".format(e))

            except IOError as e:
                logging.warn("Unknown error: {}".format(e))

        logging.info("Sleeping...")
        time.sleep(10)

    sys.exit(1)
