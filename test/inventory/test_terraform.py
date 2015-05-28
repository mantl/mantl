import terraform
import unittest


class UnittestMixin(object):

    def assertDictContainsSubsetDeeply(self, expected, actual, msg=None):
        """Compares nested dictionary structures"""
        for key, value in expected.iteritems():
            if type(value) == dict and type(actual[key]) == dict:
                self.assertDictContainsSubsetDeeply(expected[key], actual[key], msg)

            elif type(value) == list and type(actual[key]) == list:
                self.assertItemsEqual(expected[key], actual[key], "{0}: {1}".format(key, msg))

            else:
                self.assertEqual(expected[key], actual[key], msg)


class TerraformStateParserTests(UnittestMixin, unittest.TestCase):

    expected_unified_data = {
        "_meta": {
            "hostvars": {
                "mi-worker-001": {
                    "ansible_ssh_host": "130.211.119.96",
                    "ansible_ssh_user": "deploy",
                    "ansible_ssh_port": 22,
                    "consul_dc": "dc1",
                    "consul_is_server": False,
                    "metadata": {
                        "dc": "dc1",
                        "role": "worker"
                    }
                },
                "mi-control-01": {
                    "ansible_ssh_host": "104.197.77.162",
                    "ansible_ssh_user": "deploy",
                    "ansible_ssh_port": 22,
                    "consul_is_server": True,
                    "consul_dc": "dc1",
                    "metadata": {
                        "dc": "dc1",
                        "role": "control"
                    }
                }

            }
        },
        "dc=dc1": {
            "hosts": [
                "mi-worker-001",
                "mi-control-01"
            ]
        },
        "role=worker": {
            "hosts": [
                "mi-worker-001"
            ]
        },
        "role=control": {
            "hosts": [
                "mi-control-01"
            ]
        },
        "dc1" : {
            "hosts": ["mi-control-01", "mi-worker-001"]
        },
        "consul_servers": {
            "hosts": ["mi-control-01"]
        },
         "vault_servers": {
            "hosts": ["mi-control-01"]
        },
         "zookeeper_servers": {
            "hosts": ["mi-control-01"]
        },
         "mesos_leaders": {
            "hosts": ["mi-control-01"]
        },
         "marathon_servers": {
            "hosts": ["mi-control-01"]
        },
        "consul_clients": {
            "hosts": ["mi-worker-001"]
        },
        "mesos_followers": {
            "hosts": ["mi-worker-001"]
        },
        "proxy_servers": {
            "hosts": ["mi-worker-001"]
        },


    }

    def load_tfstate(self, mock_filenames):
        return terraform.iterresources(mock_filenames)

    def parse(self, mock_filenames):
        resources = self.load_tfstate(mock_filenames)
        hosts = terraform.iterhosts(resources)
        return terraform.query_list(hosts)

    def test_gce_ansible_vars(self):
        parsed = self.parse(['inventory/gce.state.snapshot'])
        self.assertDictContainsSubsetDeeply(self.expected_unified_data, parsed)

    def test_aws_ansible_vars(self):
        parsed = self.parse(['inventory/aws.state.snapshot'])
        self.assertDictContainsSubsetDeeply(self.expected_unified_data, parsed)
