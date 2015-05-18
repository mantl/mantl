#!/usr/bin/env python
"""\
Dynamic inventory for Terraform - finds all `.tfstate` files below the working
directory and generates an inventory based on them.
"""
from __future__ import unicode_literals, print_function
import argparse
from collections import defaultdict
import json
import os
import sys

parser = argparse.ArgumentParser(__file__, __doc__)
modes = parser.add_mutually_exclusive_group()
modes.add_argument('--list', action='store_true', help='list all variables')
modes.add_argument('--host', help='list variables for a single host')
parser.add_argument('--pretty',
                    action='store_true',
                    help='pretty-print output JSON')
parser.add_argument('--nometa',
                    action='store_true',
                    help='with --list, exclude hostvars')


def tfstates(root=None):
    root = root or os.getcwd()
    for dirpath, _, filenames in os.walk(root):
        for name in filenames:
            if os.path.splitext(name)[-1] == '.tfstate':
                yield os.path.join(dirpath, name)


def iterresources(filenames):
    for filename in filenames:
        with open(filename, 'r') as json_file:
            state = json.load(json_file)
            for module in state['modules']:
                for key, resource in module['resources'].items():
                    yield key, resource

## READ RESOURCES
PARSERS = {}


def iterhosts(resources):
    '''yield host tuples of (name, attributes, groups)'''
    for key, resource in resources:
        resource_type, name = key.split('.', 1)
        try:
            parser = PARSERS[resource_type]
        except KeyError:
            continue

        yield parser(resource)


def parses(prefix):
    def inner(func):
        PARSERS[prefix] = func
        return func

    return inner


def _parse_prefix(source, prefix):
    for compkey, value in source.items():
        try:
            curprefix, rest = compkey.split('.', 1)
        except ValueError:
            continue

        if curprefix != prefix or rest == '#':
            continue

        yield rest, value


def parse_attr_list(source, prefix):
    size_key = '%s.#' % prefix
    try:
        size = int(source[size_key])
    except KeyError:
        return []

    attrs = [{} for _ in range(size)]
    for compkey, value in _parse_prefix(source, prefix):
        nth, key = compkey.split('.', 1)
        attrs[int(nth)][key] = value

    return attrs


def parse_dict(source, prefix):
    return dict(_parse_prefix(source, prefix))


def parse_list(source, prefix):
    return [value for _, value in _parse_prefix(source, prefix)]

@parses('openstack_compute_instance_v2')
def openstack_host(resource, tfvars=None):
    raw_attr = resource['primary']['attributes']
    name = raw_attr['name']
    groups = []

    attrs = {}

    attrs.update({
        'consul_dc': raw_attr['region']
    })

    try:
        attrs.update({
            'ansible_ssh_host': raw_attr['access_ip_v4'],
        })
    except (KeyError, ValueError):
        attrs.update({
            'ansible_ssh_host': '',
        })

    groups.append('role=%s' % raw_attr['metadata.role'])

    return name, attrs, groups


@parses('google_compute_instance')
def gce_host(resource, tfvars=None):
    name = resource['primary']['id']
    raw_attrs = resource['primary']['attributes']
    groups = []

    # network interfaces
    interfaces = parse_attr_list(raw_attrs, 'network_interface')
    for interface in interfaces:
        interface['access_config'] = parse_attr_list(interface,
                                                     'access_config')
        for key in interface.keys():
            if '.' in key:
                del interface[key]

    # general attrs
    attrs = {
        'can_ip_forward': raw_attrs['can_ip_forward'] == 'true',
        'disks': parse_attr_list(raw_attrs, 'disk'),
        'machine_type': raw_attrs['machine_type'],
        'metadata': parse_dict(raw_attrs, 'metadata'),
        'network': parse_attr_list(raw_attrs, 'network'),
        'network_interface': interfaces,
        'self_link': raw_attrs['self_link'],
        'service_account': parse_attr_list(raw_attrs, 'service_account'),
        'tags': parse_list(raw_attrs, 'tags'),
        'zone': raw_attrs['zone'],
        # ansible
        'ansible_ssh_port': 22,
        'ansible_ssh_user': 'deploy',
    }

    # attrs specific to microservices-infrastructure
    attrs.update({
        'consul_dc': attrs['metadata'].get('dc', attrs['zone']),
    })

    try:
        attrs.update({
            'ansible_ssh_host': interfaces[0]['access_config'][0]['nat_ip'],
            'publicly_routable': True,
        })
    except (KeyError, ValueError):
        attrs.update({
            'ansible_ssh_host': '',
            'publicly_routable': False,
        })

    # add groups based on attrs
    groups.extend('gce_image=' + disk['image'] for disk in attrs['disks'])
    groups.append('gce_machine_type=' + attrs['machine_type'])
    groups.extend('gce_metadata_%s=%s' % (key, value)
                  for (key, value) in attrs['metadata'].items()
                  if key not in set(['sshKeys']))
    groups.extend('gce_tag=' + tag for tag in attrs['tags'])
    groups.append('gce_zone=' + attrs['zone'])

    if attrs['can_ip_forward']:
        groups.append('gce_ip_forward')
    if attrs['publicly_routable']:
        groups.append('gce_publicly_routable')

    # groups specific to microservices-infrastructure
    if 'role' in attrs['metadata']:
        groups.append('role=' + attrs['metadata']['role'])
    groups.append('dc=' + attrs['consul_dc'])

    return name, attrs, groups


## QUERY TYPES
def query_host(hosts, target):
    for name, attrs, _ in hosts:
        if name == target:
            return attrs

    return {}


def query_list(hosts):
    groups = defaultdict(dict)
    meta = {}

    for name, attrs, hostgroups in hosts:
        for group in hostgroups:
            groups[group].setdefault('hosts', [])
            groups[group]['hosts'].append(name)

        meta[name] = attrs

    groups['_meta'] = {'hostvars': meta}
    return groups


def main():
    args = parser.parse_args()
    if not args.list and not args.host:
        print('error: one of --list or --host is required', file=sys.stderr)
        print('{}')
        return 1

    hosts = iterhosts(iterresources(tfstates()))
    if args.list:
        output = query_list(hosts)
        if args.nometa:
            del output['_meta']
    else:
        output = query_host(hosts, args.host)

    print(json.dumps(output, indent=4 if args.pretty else None))
    return 0


if __name__ == '__main__':
    sys.exit(main())
