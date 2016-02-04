#!/usr/bin/env python2
from __future__ import print_function
import unittest
import healthchecks

json_example = """
{
        "aws_tag_role=control": {
                "hosts": ["mantl-ci-21-1-control-01", "mantl-ci-21-1-control-02", "mantl-ci-21-1-control-03"]
        },
        "aws_ami=ami-f77fbeb3": {
                "hosts": ["mantl-ci-21-1-control-01", "mantl-ci-21-1-control-02", "mantl-ci-21-1-control-03", "mantl-ci-21-1-edge-02", "mantl-ci-21-1-edge-01", "mantl-ci-21-1-worker-001", "mantl-ci-21-1-worker-002", "mantl-ci-21-1-worker-003"]
        },
        "aws_tag_Name=mantl-ci-21-1-edge-02": {
                "hosts": ["mantl-ci-21-1-edge-02"]
        },
        "_meta": {
                "hostvars": {
                        "mantl-ci-21-1-worker-001": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "54.67.105.69",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.127.6",
                                        "dns": "ip-10-0-127-6.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "20",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-7f0c10cd",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "worker",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-worker-001"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "54.67.105.69",
                                "ansible_ssh_user": "centos",
                                "role": "worker",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.127.6",
                                "consul_is_server": false,
                                "public": {
                                        "ip": "54.67.105.69",
                                        "dns": "ec2-54-67-105-69.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f36e6196", "sg-ff6e619a"]
                        },
                        "mantl-ci-21-1-worker-003": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "54.183.129.91",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.245.212",
                                        "dns": "ip-10-0-245-212.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "20",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-7e0c10cc",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "worker",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-worker-003"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "54.183.129.91",
                                "ansible_ssh_user": "centos",
                                "role": "worker",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.245.212",
                                "consul_is_server": false,
                                "public": {
                                        "ip": "54.183.129.91",
                                        "dns": "ec2-54-183-129-91.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f36e6196", "sg-ff6e619a"]
                        },
                        "mantl-ci-21-1-worker-002": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "54.153.10.49",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.27.231",
                                        "dns": "ip-10-0-27-231.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "20",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-870c1035",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "worker",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-worker-002"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "54.153.10.49",
                                "ansible_ssh_user": "centos",
                                "role": "worker",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.27.231",
                                "consul_is_server": false,
                                "public": {
                                        "ip": "54.153.10.49",
                                        "dns": "ec2-54-153-10-49.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f36e6196", "sg-ff6e619a"]
                        },
                        "mantl-ci-21-1-control-01": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "52.53.226.175",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.221.136",
                                        "dns": "ip-10-0-221-136.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "20",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-e50c1057",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "control",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-control-01"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "52.53.226.175",
                                "ansible_ssh_user": "centos",
                                "role": "control",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.221.136",
                                "consul_is_server": true,
                                "public": {
                                        "ip": "52.53.226.175",
                                        "dns": "ec2-52-53-226-175.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f86e619d", "sg-fd6e6198", "sg-f36e6196"]
                        },
                        "mantl-ci-21-1-control-02": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "54.183.112.122",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.29.8",
                                        "dns": "ip-10-0-29-8.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "20",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-c0130f72",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "control",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-control-02"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "54.183.112.122",
                                "ansible_ssh_user": "centos",
                                "role": "control",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.29.8",
                                "consul_is_server": true,
                                "public": {
                                        "ip": "54.183.112.122",
                                        "dns": "ec2-54-183-112-122.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f86e619d", "sg-fd6e6198", "sg-f36e6196"]
                        },
                        "mantl-ci-21-1-control-03": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "52.53.236.230",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.125.177",
                                        "dns": "ip-10-0-125-177.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "20",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-7d0c10cf",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "control",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-control-03"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "52.53.236.230",
                                "ansible_ssh_user": "centos",
                                "role": "control",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.125.177",
                                "consul_is_server": true,
                                "public": {
                                        "ip": "52.53.236.230",
                                        "dns": "ec2-52-53-236-230.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f86e619d", "sg-fd6e6198", "sg-f36e6196"]
                        },
                        "mantl-ci-21-1-edge-01": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "54.153.31.110",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.248.90",
                                        "dns": "ip-10-0-248-90.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "10",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-e70c1055",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "edge",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-edge-01"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "54.153.31.110",
                                "ansible_ssh_user": "centos",
                                "role": "edge",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.248.90",
                                "consul_is_server": false,
                                "public": {
                                        "ip": "54.153.31.110",
                                        "dns": "ec2-54-153-31-110.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f36e6196", "sg-f26e6197"]
                        },
                        "mantl-ci-21-1-edge-02": {
                                "ami": "ami-f77fbeb3",
                                "ephemeral_block_device": [],
                                "availability_zone": "us-west-1b",
                                "public_ipv4": "52.53.219.47",
                                "key_name": "key-mantl-ci-21-1",
                                "private": {
                                        "ip": "10.0.12.29",
                                        "dns": "ip-10-0-12-29.us-west-1.compute.internal"
                                },
                                "tenancy": "default",
                                "ebs_block_device": [],
                                "root_block_device": [{
                                        "volume_size": "10",
                                        "iops": "0",
                                        "delete_on_termination": "true",
                                        "volume_type": "standard"
                                }],
                                "ansible_ssh_port": 22,
                                "id": "i-c3130f71",
                                "tags": {
                                        "sshUser": "centos",
                                        "role": "edge",
                                        "dc": "aws",
                                        "Name": "mantl-ci-21-1-edge-02"
                                },
                                "subnet": {
                                        "id": "subnet-4964ea10"
                                },
                                "consul_dc": "aws",
                                "ebs_optimized": false,
                                "ansible_ssh_host": "52.53.219.47",
                                "ansible_ssh_user": "centos",
                                "role": "edge",
                                "security_groups": [],
                                "provider": "aws",
                                "private_ipv4": "10.0.12.29",
                                "consul_is_server": false,
                                "public": {
                                        "ip": "52.53.219.47",
                                        "dns": "ec2-52-53-219-47.us-west-1.compute.amazonaws.com"
                                },
                                "vpc_security_group_ids": ["sg-f36e6196", "sg-f26e6197"]
                        }
                }
        }
}
"""

class TestHealthChecks(unittest.TestCase):
    def test_get_hosts_from_json(self):
        actual = healthchecks.get_hosts_from_json(json_example)
        expected = [ "52.53.226.175", "54.183.112.122", "52.53.236.230" ]
        self.assertEqual(expected, actual)

    def test_get_hosts_from_dynamic_inventory(self):
        cmd = ["echo", json_example]
        actual = healthchecks.get_hosts_from_dynamic_inventory(cmd)
        expected = [ "52.53.226.175", "54.183.112.122", "52.53.236.230" ]
        self.assertEqual(expected, actual)

        # Just make sure this doesn't traceback or anything
        cmd = ["python2", "plugins/inventory/terraform.py", "--list"]
        actual = healthchecks.get_hosts_from_dynamic_inventory(cmd)

    def test_node_health_check(self):
        self.assertFalse(healthchecks.node_health_check("52.53.226.175"))

    def test_cluster_health_check(self):
        ips = [ "52.53.226.175" ]
        self.assertEqual(1, healthchecks.cluster_health_check(ips))

if __name__ == '__main__':
    unittest.main()
