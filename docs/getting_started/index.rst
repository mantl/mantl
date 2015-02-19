Getting Started
===============

.. note:: This document assumes you have a `working Ansible
          installation`_. If you don't, install Ansible before
          continuing.

The Microservices Infrastructure project uses Ansible to bring up
nodes and clusters. This generally means that you need three things:

 1. hosts to use as the base for your cluster
 2. an `inventory file`_ with the hosts you want to be modified.
 3. a playbook to show which components should go where.

Getting Hosts
-------------

The playbooks and roles in this project will work on whatever provider
(or metal) you care to spin up, as long as it can run CentOS 7 or
equivalent. However, here are some guides to get started on common
platforms:

.. toctree::
   :maxdepth: 1

   openstack.rst

Inventory
---------

Let's set up an inventory file that will control a single datacenter:
``tx1``. We'll be setting up 9 machines: 3 leaders, 3 followers, and 3
ZooKeepers.

.. code-block:: dosini

    leader1    ansible_ssh_hostname=10.10.10.10
    leader2    ansible_ssh_hostname=10.10.10.11
    leader3    ansible_ssh_hostname=10.10.10.12
    follower1  ansible_ssh_hostname=10.10.10.13
    follower2  ansible_ssh_hostname=10.10.10.14
    follower3  ansible_ssh_hostname=10.10.10.15
    zk1        ansible_ssh_hostname=10.10.10.16
    zk2        ansible_ssh_hostname=10.10.10.17
    zk3        ansible_ssh_hostname=10.10.10.18

    [consul_server]
    leader[1:3]
    follower[1:3]
    zk[1:3]

    [dc_tx1]
    leader1[1:3]
    follower1[1:3]
    zk1[1:3]

    [dc_tx1:vars]
    consul_server_group=dc_tx1
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

We put 6 servers in the ``consul_server`` group. These will all
discover each other as part of the Ansible run and form a cluster. If
you had more than one datacenter, you can specify an additional set of
servers (in, for example, ``dc_ny1``) and use the
``consul-join-wan.yml`` playbook to join them together. Note that
we're setting :data:`consul_server_group` and :data:`consul_dc` to
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

Playbook
--------

Once you're able to connect to your nodes, you'll want to use a
`playbook`_ to tell Ansible what to put where. This playbook will
bring up the cluster of nodes that we've specified in our inventory.

.. note:: In the Mesos plays we're setting some group variables in the
          playbook instead of the inventory. This can be useful when
          your inventory is `generated dynamically`_. It is typically
          best to keep your variables all in one place, so consider
          this for demonstration purposes only.

.. code-block:: yaml+jinja

    ---
    - hosts: all
      roles:
        - common
        - docker
        - dnsmasq
    
    # this syntax essentially means "take all the servers in dc1 which
    # are also in consul_server"
    # see: http://docs.ansible.com/intro_patterns.html
    - hosts: dc_tx1:&consul_server
      # to speed things up we turn off gather_facts after we've
      # already done it on the host.
      gather_facts: no
      # consul servers should be updated only a few at a time so that
      # the cluster doesn't lose quorum. We've set it to 1 here because
      # that's the maxiumum you can lose at once in a 3-node cluster.
      serial: 1
      roles:
        - consul
    
    # again, we don't have any hosts in ny1, so this is just how it
    # would run if we *did*.
    - hosts: ny1:&consul_server
      gather_facts: no
      serial: 1
      roles:
        - consul
    
    - hosts: all
      gather_facts: no
      roles:
        - registrator
    
    # remember that zk_id and other ZooKeeper variables are set in our
    # inventory in this case, so we don't need to define them in the
    # playbook
    - hosts: zookeeper_servers
      gather_facts: no
      roles:
        - zookeeper
    
    - hosts: mesos_leaders
      gather_facts: no
      roles: 
        # here we're providing the value of mesos_mode. It will only
        # be visible within the role.
        - mesos
          mesos_mode: leader
        - marathon
    
    - hosts: mesos_followers
      gather_facts: no
      roles: 
        - mesos
          mesos_mode: follower

Run this playbook with ``ansible-playbook -i /path/to/your/inventory
/path/to/your/playbook.yml``. It will take a while for everything to
come up as machines will have to download quite a few dependencies if
they're fresh.

Finishing Up
------------

Once you've run the playbook successfully, you should be able to
access Mesos on any of your ``mesos_leader`` nodes on port 5050, and
Marathon on port 8080.
        
.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
.. _inventory file: http://docs.ansible.com/intro_inventory.html
.. _playbook: http://docs.ansible.com/playbooks.html
.. _working Ansible installation: http://docs.ansible.com/intro_installation.html#installing-the-control-machine
