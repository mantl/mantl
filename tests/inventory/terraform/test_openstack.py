# -*- coding: utf-8 -*-
import pytest


@pytest.fixture
def openstack_host():
    from terraform import openstack_host
    return openstack_host


@pytest.fixture
def openstack_resource():
    return {
        "type": "openstack_compute_instance_v2",
        "primary": {
            "id": "81467bb5-e214-4764-b501-8b59892d88e2",
            "attributes": {
                "access_ip_v4": "173.39.243.27",
                "access_ip_v6": "",
                "flavor_id": "c6580dce-3cf4-488a-8eb0-8d3766c5e6f7",
                "flavor_name": "CO2-2XLarge",
                "id": "81467bb5-e214-4764-b501-8b59892d88e2",
                "image_id": "1bbd1f1f-d32c-43ca-a727-3b2b075c3e28",
                "image_name": "centos-7_x86_64-2015-01-27-v6",
                "key_pair": "ansible_pubkey_sborrelli",
                "metadata.#": "1",
                "metadata.role": "control",
                "name": "mi-control-01",
                "network.#": "1",
                "network.0.fixed_ip_v4": "173.39.243.27",
                "network.0.fixed_ip_v6": "",
                "network.0.mac": "fa:16:3e:12:13:d7",
                "network.0.name": "public-direct-600",
                "network.0.port": "",
                "network.0.uuid": "e7b1be4f-e0d2-4024-948f-b9e6c4911123",
                "region": "eu-amsterdam-1",
                "security_groups.#": "1",
                "security_groups.0": "default"
            }
        }
    }


def test_name(openstack_resource, openstack_host):
    name, _, _ = openstack_host(openstack_resource)
    assert name == 'mi-control-01'


@pytest.mark.parametrize('attr,should', {
    'access_ip_v4': '173.39.243.27',
    'access_ip_v6': '',
    'flavor': {
        'id': 'c6580dce-3cf4-488a-8eb0-8d3766c5e6f7',
        'name': 'CO2-2XLarge',
    },
    'id': '81467bb5-e214-4764-b501-8b59892d88e2',
    'image': {
        'id': '1bbd1f1f-d32c-43ca-a727-3b2b075c3e28',
        'name': 'centos-7_x86_64-2015-01-27-v6',
    },
    'key_pair': 'ansible_pubkey_sborrelli',
    'metadata': {'role': 'control', },
    'network': [{
        'fixed_ip_v4': '173.39.243.27',
        'fixed_ip_v6': '',
        'mac': 'fa:16:3e:12:13:d7',
        'name': 'public-direct-600',
        'port': '',
        'uuid': 'e7b1be4f-e0d2-4024-948f-b9e6c4911123'
    }],
    'region': 'eu-amsterdam-1',
    'security_groups': ['default'],
    # ansible
    'ansible_ssh_user': 22,
    'ansible_ssh_user': 'centos',
    'ansible_ssh_host': '173.39.243.27',
    'publicly_routable': True,
    # mi
    'consul_dc': 'eu-amsterdam-1',
    'role': 'control',
    # and the bugfix
    'use_host_domain': True,
    'host_domain': 'novalocal',
}.items())
def test_attrs(openstack_resource, openstack_host, attr, should):
    _, attrs, _ = openstack_host(openstack_resource)
    assert attr in attrs
    assert attrs[attr] == should

@pytest.mark.parametrize('group', [
    'os_image=centos-7_x86_64-2015-01-27-v6',
    'os_flavor=CO2-2XLarge',
    'os_metadata_role=control',
    'os_region=eu-amsterdam-1',
    'role=control',
    'dc=eu-amsterdam-1',
])
def test_groups(openstack_resource, openstack_host, group):
    _, _, groups = openstack_host(openstack_resource)
    assert group in groups
