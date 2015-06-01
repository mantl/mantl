#! /usr/bin/python
# Copyright 2015 Ray Rodriguez
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import collectd
import json
import urllib2
import socket
import collections

PREFIX = "mesos-slave"
MESOS_HOST = "localhost"
MESOS_PORT = 5051
MESOS_VERSION = "0.21.0"
MESOS_URL = ""
VERBOSE_LOGGING = False

Stat = collections.namedtuple('Stat', ('type', 'path'))

STATS_CUR = {}

# DICT: Common Metrics in 0.19.0, 0.20.0 and 0.21.0
STATS_MESOS = {
    # Slave
    'slave/frameworks_active': Stat("gauge", "slave/frameworks_active"),
    'slave/invalid_framework_messages': Stat("counter", "slave/invalid_framework_messages"),
    'slave/invalid_status_updates': Stat("counter", "slave/invalid_status_updates"),
    'slave/recovery_errors': Stat("counter", "slave/recovery_errors"),
    'slave/registered': Stat("gauge", "slave/registered"),
    'slave/tasks_failed': Stat("counter", "slave/tasks_failed"),
    'slave/tasks_finished': Stat("counter", "slave/tasks_finished"),
    'slave/tasks_killed': Stat("counter", "slave/tasks_killed"),
    'slave/tasks_lost': Stat("counter", "slave/tasks_lost"),
    'slave/tasks_running': Stat("gauge", "slave/tasks_running"),
    'slave/tasks_starting': Stat("gauge", "slave/tasks_starting"),
    'slave/tasks_staging': Stat("gauge", "slave/tasks_staging"),
    'slave/uptime_secs': Stat("gauge", "slave/uptime_secs"),
    'slave/valid_framework_messages': Stat("counter", "slave/valid_framework_messages"),
    'slave/valid_status_updates': Stat("counter", "slave/valid_status_updates"),

    # System
    'system/cpus_total': Stat("gauge", "system/cpus_total"),
    'system/load_15min': Stat("gauge", "system/load_15min"),
    'system/load_1min': Stat("gauge", "system/load_1min"),
    'system/load_5min': Stat("gauge", "system/load_5min"),
    'system/mem_free_bytes': Stat("bytes", "system/mem_free_bytes"),
    'system/mem_total_bytes': Stat("bytes", "system/mem_total_bytes")
}

# DICT: Mesos 0.19.0, 0.19.1
STATS_MESOS_019 = {
}

# DICT: Mesos 0.20.0, 0.20.1
STATS_MESOS_020 = {
    'slave/executors_registering': Stat("gauge", "slave/executors_registering"),
    'slave/executors_running': Stat("gauge", "slave/executors_running"),
    'slave/executors_terminating': Stat("gauge", "slave/executors_terminating"),
    'slave/executors_terminated': Stat("counter", "slave/executors_terminated")
}

# DICT: Mesos 0.21.0, 0.21.1
STATS_MESOS_021 = {
    'slave/cpus_percent': Stat("percent", "slave/cpus_percent"),
    'slave/cpus_total': Stat("gauge", "slave/cpus_total"),
    'slave/cpus_used': Stat("gauge", "slave/cpus_used"),
    'slave/disk_percent': Stat("percent", "slave/disk_percent"),
    'slave/disk_total': Stat("gauge", "slave/disk_total"),
    'slave/disk_used': Stat("gauge", "slave/disk_used"),
    'slave/mem_percent': Stat("percent", "slave/mem_percent"),
    'slave/mem_total': Stat("gauge", "slave/mem_total"),
    'slave/mem_used': Stat("gauge", "slave/mem_used"),
    'slave/executors_registering': Stat("gauge", "slave/executors_registering"),
    'slave/executors_running': Stat("gauge", "slave/executors_running"),
    'slave/executors_terminating': Stat("gauge", "slave/executors_terminating"),
    'slave/executors_terminated': Stat("counter", "slave/executors_terminated")
}

# FUNCTION: Collect stats from JSON result
def lookup_stat(stat, json):
    val = dig_it_up(json, STATS_CUR[stat].path)

    # Check to make sure we have a valid result
    # dig_it_up returns False if no match found
    if not isinstance(val, bool):
        return val
    else:
        return None


def configure_callback(conf):
    """Received configuration information"""
    global MESOS_HOST, MESOS_PORT, MESOS_URL, VERBOSE_LOGGING, STATS_CUR
    for node in conf.children:
        if node.key == 'Host':
            MESOS_HOST = node.values[0]
        elif node.key == 'Port':
            MESOS_PORT = int(node.values[0])
        elif node.key == 'Verbose':
            VERBOSE_LOGGING = bool(node.values[0])
        elif node.key == 'Version':
            MESOS_VERSION = node.values[0]
        else:
            collectd.warning('mesos-slave plugin: Unknown config key: %s.' % node.key)

    if MESOS_VERSION == "0.19.0" or MESOS_VERSION == "0.19.1":
        STATS_CUR = dict(STATS_MESOS.items() + STATS_MESOS_019.items())
    elif MESOS_VERSION == "0.20.0" or MESOS_VERSION == "0.20.1":
        STATS_CUR = dict(STATS_MESOS.items() + STATS_MESOS_020.items())
    elif MESOS_VERSION == "0.21.0" or MESOS_VERSION == "0.21.1":
        STATS_CUR = dict(STATS_MESOS.items() + STATS_MESOS_021.items())
    else:
        STATS_CUR = dict(STATS_MESOS.items() + STATS_MESOS_021.items())

    MESOS_URL = "http://" + MESOS_HOST + ":" + str(MESOS_PORT) + "/metrics/snapshot"

    log_verbose('mesos-slave plugin configured with version=%s, host=%s, port=%s, url=%s' % (MESOS_VERSION, MESOS_HOST, MESOS_PORT, MESOS_URL))


def fetch_stats():
    try:
        result = json.load(urllib2.urlopen(MESOS_URL, timeout=10))
    except urllib2.URLError, e:
        collectd.error('mesos-slave plugin: Error connecting to %s - %r' % (MESOS_URL, e))
        return None
    return parse_stats(result)


def parse_stats(json):
    """Parse stats response from Mesos slave"""
    for name, key in STATS_CUR.iteritems():
        result = lookup_stat(name, json)
        dispatch_stat(result, name, key)


def dispatch_stat(result, name, key):
    """Read a key from info response data and dispatch a value"""
    if result is None:
        collectd.warning('mesos-slave plugin: Value not found for %s' % name)
        return
    estype = key.type
    value = result
    log_verbose('Sending value[%s]: %s=%s' % (estype, name, value))

    val = collectd.Values(plugin='mesos-slave')
    val.type = estype
    val.type_instance = name
    val.values = [value]
    val.dispatch()


def read_callback():
    log_verbose('Read callback called')
    stats = fetch_stats()


def dig_it_up(obj, path):
    try:
        if type(path) in (str, unicode):
            path = path.split('.')
        return reduce(lambda x, y: x[y], path, obj)
    except:
        return False


def log_verbose(msg):
    if not VERBOSE_LOGGING:
        return
    collectd.info('mesos-slave plugin [verbose]: %s' % msg)

collectd.register_config(configure_callback)
collectd.register_read(read_callback)
