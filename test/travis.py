#!/usr/bin/env python2
from __future__ import print_function

import base64
import json
import logging
import os
import os.path
import socket
import ssl
import subprocess
import sys
import time
import urllib2

# FROM plugins/inventory/terraform.py
sys.path += [os.getcwd() + "/plugins/inventory"]
# PYTHON_PATH is added to in .travis.yml
import terraform as tf

LINT_PROVIDERS = ["clc", "softlayer", "triton"]
DEPLOY_PROVIDERS = ["gce", "aws", "do"]

## TRAVIS STEPS

def install():
    bin_dir = "{}/bin".format(os.environ['HOME'])
    ssh_dir = "{}/.ssh".format(os.environ['HOME'])
    run_cmds([
        (["pip", "install", "-r", "requirements.txt"], 1),
        (["curl", "-Lo", "terraform.zip",  "https://releases.hashicorp.com/terraform/{0}/terraform_{0}_linux_amd64.zip".format(os.environ['TERRAFORM_VERSION'])], 1),
        (["mkdir", "-p", bin_dir], 1),
        (["unzip", "-d", bin_dir, "terraform.zip"], 1),
        (["mkdir", "-p", ssh_dir], 1),
        (["ssh-keygen", "-N", '', "-f", ssh_dir + "/id_rsa"], 1),
        (["ssh-add"], 1),
    ])


def script():

    # Filter out commits that are documentation changes.
    commit_range = os.environ.get("TRAVIS_COMMIT_RANGE", "master..HEAD")
    diff_names = str(subprocess.check_output(["git",  "diff",  "--name-only", commit_range]))

    not_docfiles = filter_not_docfiles(diff_names)
    if len(not_docfiles) < 1:
        logging.info("All of the changes were in documentation. Skipping build.")
        sys.exit(0)

    # linter commands
    cmds = [
        (["ln", "-s", os.environ["TERRAFORM_FILE"], "terraform.tf"], 1),
        (['./security-setup'], 1),
        (["terraform", "get"], 1),
        (["terraform", "plan", "--input=false", "--refresh=false"], 1),
    ]

    if os.environ.get("PROVIDER", None) in DEPLOY_PROVIDERS:
        ansible_prefix = [
            "ansible-playbook", "-e", "@security.yml", "--private-key",
            "~/.ssh/id_rsa"
        ]

        cmds.extend([
            (["terraform", "apply"], 1),
            (ansible_prefix + ["playbooks/wait-for-hosts.yml"], 3),
            (ansible_prefix + ["playbooks/upgrade-packages.yml"], 1),
            (ansible_prefix + ["sample.yml"], 1),
        ])

    if not run_cmds(cmds, fail_sequential=True):
        sys.exit(1)

    sys.exit(0)


def after_script():
    """Cleanup after ci_build"""

    destroy_cmd = ["terraform",  "destroy",  "-force"]
    logging.info("Destroying cloud provider resources")

    sys.exit(run_cmd(destroy_cmd))
    # send slack notification


## PURE-ISH FUNCTIONS

def run_cmd(cmd, attempts=1):
    """ Runs a command attempts times, logging its output. Returns True if it
    succeeds once, or False if it never does. """
    try:
        for i in range(attempts):
            proc = subprocess.Popen(cmd, stdin=open(os.devnull, "r"))
            proc.wait()
            if not proc.returncode == 0:
                print("Command ", str(cmd), " failed")
            else:
                print("Command ", str(cmd), " succeeded.")
                return True
            time.sleep(3)
        return False
    except OSError as e:
        print("Error while attempting to run command ", cmd)
        print(e)


def run_cmds(cmds, fail_sequential=False):
    """ Run a list of ([args], tries) tuples, aborting the run if a single one
    fails and fail_sequential is set to True.
    Returns True if all succeed, and False if any fail.
    """
    to_return = True
    for (cmd, tries) in cmds:
        # If we've failed already and fail_sequential is set, don't continue
        if not to_return and fail_sequential:
            return False
        # Otherwise, attempt to run the current command
        elif run_cmd(cmd, attempts=tries):
            continue
        # If it fails, set the exit code appropriately
        else:
            to_return = False
    return to_return


def filter_not_docfiles(diff_names):

    is_doc = lambda f: f.startswith('docs') or any([f.endswith(ext) for ext in ['md', 'rst']])
    return [f for f in diff_names.split() if not is_doc(f)]


def deploy_to_cloud_cmds():
    return cmds


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
        logging.info('security.yml missing, return "" for unit test instead')
        return ""


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


def health_checks():
    logging.info("Performing health checks")

    if os.environ.get("PROVIDER", None) in LINT_PROVIDERS:
        logging.info("Skipping health checks for provider")
        sys.exit(0)

    logging.info("Getting hosts")

    hosts = []
    host_data = tf.query_list(tf.iterhosts(tf.iterresources(tf.tfstates())))
    host_data = host_data["_meta"]["hostvars"]

    for host, dic in host_data.iteritems():
        if dic.get("role", "").lower() == "control":
            hosts.append( (host, dic["public_ipv4"]) )

    if len(hosts) == 0:
        logging.error("terraform.py reported no control hosts")
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


if __name__ == "__main__":
    logfmt = "%(asctime)s  %(levelname)s  %(message)s"
    logging.basicConfig(format=logfmt, level=logging.INFO)

    if len(sys.argv) > 1:
        if sys.argv[1] == 'install':
            install()
        elif sys.argv[1] == 'script':
            script()
        elif sys.argv[1] == 'health_checks':
            health_checks()
        elif sys.argv[1] == 'after_script':
            after_script()
        else:
            logging.critical("Command not supported.")
            sys.exit(1)

    else:
        logging.critical("Usage: travis.py <cmd>")
        sys.exit(1)
