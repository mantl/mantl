Inventory
---------

Below is an example inventory file that will control a single datacenter:
``tx1``. We'll be setting up 9 machines: 3 leaders, 3 followers, and 3
ZooKeepers.

.. code-block:: dosini

    leader1    ansible_ssh_host=10.10.10.10
    leader2    ansible_ssh_host=10.10.10.11
    leader3    ansible_ssh_host=10.10.10.12
    follower1  ansible_ssh_host=10.10.10.13
    follower2  ansible_ssh_host=10.10.10.14
    follower3  ansible_ssh_host=10.10.10.15
    zk1        ansible_ssh_host=10.10.10.16
    zk2        ansible_ssh_host=10.10.10.17
    zk3        ansible_ssh_host=10.10.10.18

    [consul_servers]
    leader[1:3]
    follower[1:3]
    zk[1:3]

    [dc_tx1]
    leader1[1:3]
    follower1[1:3]
    zk1[1:3]

    [dc_tx1:vars]
    consul_servers_group=dc_tx1
    consul_dc=tx1

    [zookeeper_servers:vars]
    zookeeper_service_tags=ensemble1

    [zookeeper_servers]
    zk1 zk_id=1
    zk2 zk_id=2
    zk3 zk_id=3

    [mesos_leaders]
    leader[1:3]

    [mesos_followers]
    follower[1:3]

    [marathon_servers]
    leader[1:3]

We put 6 servers in the ``consul_servers`` group. These will all
discover each other as part of the Ansible run and form a cluster. If
you had more than one datacenter, you can specify an additional set of
servers (in, for example, ``dc_ny1``) and use the
``consul-join-wan.yml`` playbook to join them together. Note that
we're setting :data:`consul_servers_group` and :data:`consul_dc` to
appropriate values for this datacenter as well.

We're also setting some group and host variables here for
ZooKeeper. In particular, we're setting the
:data:`zookeeper_service_tags` for ZooKeeper to "ensemble1" on the
group level. That means that every machine in the group will have that
variable set to that value. We also are setting :data:`zk_id` on each
individual node. This is currently required for proper ZooKeeper
operation.

Once you have your inventory file in place, test your connections
using the command ``ansible all -i /path/to/your/inventory -m
ping``. All your nodes should respond with "pong". If they don't,
check your connection by adding ``-vvvv`` for verbose SSH debugging
and try again to view the errors in more detail.
