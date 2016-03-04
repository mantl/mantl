#!/usr/bin/env python2
from __future__ import print_function
import subprocess
from sys import exit
from os import devnull
from time import sleep

def run_cmd(cmd, attempts=1):
    """ Runs a command attempts times, logging its output. Returns True if it
    succeeds once, or False if it never does. """
    try:
        for i in range(attempts):
            proc = subprocess.Popen(cmd, stdin=open(devnull, "r"))
            proc.wait()
            if not proc.returncode == 0:
                print("Command ", str(cmd), " failed")
            else:
                print("Command ", str(cmd), " succeeded.")
                return True
            sleep(3)
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

if __name__ == "__main__":
    ap = [
        "ansible-playbook", "-e", "@security.yml", "--private-key",
        "~/.ssh/id_rsa"
    ]
    setup = [
        (["python2", "security-setup"], 1),
        (["terraform", "get"], 1),
        (["terraform", "plan"], 1),
        (["terraform", "apply"], 1),
        (ap + ["playbooks/wait-for-hosts.yml"], 3),
        (ap + ["-e", "serial=0", "playbooks/upgrade-packages.yml"], 1),
        (ap + ["sample.yml"], 1),
        (["python2", "testing/healthchecks.py"], 2)
    ]
    debug = []

    if not run_cmds(setup, fail_sequential=True):
        run_cmds(debug)
        exit(1)
    # Travis works on the teardown, so there's no need to do so here.
