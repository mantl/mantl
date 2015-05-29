# -*- coding: utf-8 -*-
import pytest


@pytest.fixture
def aws_host():
    from terraform import aws_host
    return aws_host


@pytest.fixture
def aws_resource():
    return {
        "type": "aws_instance",
        "depends_on": ["aws_key_pair.deployer", "aws_security_group.control",
                       "aws_subnet.main", "aws_vpc.main"],
        "primary": {
            "id": "i-c99f6f60",
            "attributes": {
                "ami": "ami-fe100a96",
                "associate_public_ip_address": "true",
                "availability_zone": "us-east-1e",
                "ebs_block_device.#": "0",
                "ebs_optimized": "false",
                "ephemeral_block_device.#": "0",
                "id": "i-c99f6f60",
                "instance_type": "m1.medium",
                "key_name": "key-mi",
                "private_dns": "ip-10-0-152-191.ec2.internal",
                "private_ip": "10.0.152.191",
                "public_dns": "ec2-52-7-74-115.compute-1.amazonaws.com",
                "public_ip": "52.7.74.115",
                "root_block_device.#": "1",
                "root_block_device.0.delete_on_termination": "true",
                "root_block_device.0.iops": "18",
                "root_block_device.0.volume_size": "6",
                "root_block_device.0.volume_type": "gp2",
                "security_groups.#": "0",
                "subnet_id": "subnet-1155c03a",
                "tags.#": "4",
                "tags.Name": "mi-control-01",
                "tags.dc": "aws",
                "tags.role": "control",
                "tags.sshUser": "ec2-user",
                "tenancy": "default",
                "vpc_security_group_ids.#": "2",
                "vpc_security_group_ids.1636704399": "sg-9c360cf8",
                "vpc_security_group_ids.3543019159": "sg-9d360cf9"
            },
            "meta": {"schema_version": "1"}
        }
    }


def test_name(aws_resource, aws_host):
    name, _, _ = aws_host(aws_resource)
    assert name == 'mi-control-01'


@pytest.mark.parametrize('attr,should', {
    'ami': 'ami-fe100a96',
    'availability_zone': 'us-east-1e',
    'ebs_block_device': [],
    'ebs_optimized': False,
    'ephemeral_block_device': [],
    'id': 'i-c99f6f60',
    'key_name': 'key-mi',
    'private': {'ip': '10.0.152.191',
                'dns': 'ip-10-0-152-191.ec2.internal'},
    'public': {
        'ip': '52.7.74.115',
        'dns': 'ec2-52-7-74-115.compute-1.amazonaws.com'
    },
    'role': 'control',
    'root_block_device': [{
        'volume_size': '6',
        'iops': '18',
        'delete_on_termination': 'true',
        'volume_type': 'gp2'
    }],
    'security_groups': [],
    'subnet': {'id': 'subnet-1155c03a'},
    'tags': {
        'sshUser': 'ec2-user',
        'role': 'control',
        'dc': 'aws',
        'Name': 'mi-control-01'
    },
    'tenancy': 'default',
    'vpc_security_group_ids': ['sg-9c360cf8', 'sg-9d360cf9'],
    # ansible
    'ansible_ssh_host': '52.7.74.115',
    'ansible_ssh_port': 22,
    'ansible_ssh_user': 'ec2-user',
    # mi
    'consul_dc': 'aws',
}.items())
def test_attrs(aws_resource, aws_host, attr, should):
    _, attrs, _ = aws_host(aws_resource)
    assert attr in attrs
    assert attrs[attr] == should


@pytest.mark.parametrize(
    'group',
    ['aws_ami=ami-fe100a96', 'aws_az=us-east-1e', 'aws_key_name=key-mi',
     'aws_tenancy=default', 'aws_tag_sshUser=ec2-user', 'aws_tag_role=control',
     'aws_tag_dc=aws', 'aws_tag_Name=mi-control-01',
     'aws_vpc_security_group=sg-9c360cf8',
     'aws_vpc_security_group=sg-9d360cf9', 'aws_subnet_id=subnet-1155c03a'])
def test_groups(aws_resource, aws_host, group):
    _, _, groups = aws_host(aws_resource)
    assert group in groups
