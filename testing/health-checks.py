#!/usr/bin/env python
from __future__ import print_function
import sys
import json
import base64
from time import sleep
import urllib2


NUM_SKIPS = 0
NUM_FAILS = 0
EXIT_STATUS = 0


def get_credentials():
    yaml_key = "chronos_http_credentials:"
    with open('security.yml') as f:
        for line in f:
            if yaml_key in line:
                # credentials are the whole string after the key
                credentials = line[len(yaml_key):].strip()
                # only grab what we need
                return credentials


def node_health_check(node_address):
    global NUM_SKIPS
    global NUM_FAILS
    global EXIT_STATUS
    url = "https://" + node_address + "/consul/v1/health/state/any"
    auth = b'Basic ' + base64.b64encode(get_credentials())
    request = urllib2.Request(url)
    request.add_header("Authorization", auth)
    try:
        f = urllib2.urlopen(request)
        health_checks = json.loads(f.read().decode('utf8'))

        for check in health_checks:
            print(check['Name'] + ": " + check['Status'])
            if check['Status'] != "passing":
                NUM_FAILS += 1
                EXIT_STATUS = 1
    except Exception, e:
        print("Skipping IP ", node_address, " due to this error\n", e)
        NUM_SKIPS += 1


def cluster_health_check(ip_addresses):
    for node_address in ip_addresses:
        print("Testing node at IP: " + node_address)
        node_health_check(node_address)
        print("Done testing " + node_address)


if __name__ == "__main__":

    print("Starting Health Check script.")
    print("Waiting for services")
    sleep(60*2)  # two minutes
    address_list = sys.argv[1:]
    print("Health check starting now")
    cluster_health_check(address_list)
    msg = "Health check finished, with " + str(NUM_SKIPS) + " skips"
    msg += " and " + str(NUM_FAILS) + " failures"
    print(msg)
    sys.exit(EXIT_STATUS)
