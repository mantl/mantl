Getting Started
===============

.. note:: This document assumes you have a `working Ansible
          installation`_. If you don't, install Ansible before
          continuing.

The Microservices Infrastructure project uses Ansible to bring up
nodes and clusters. This generally means that you need two things:

 #. an `inventory file`_ with the hosts you want to be modified.
 #. a playbook to show which components should go where.

.. _working Ansible installation: http://docs.ansible.com/intro_installation.html#installing-the-control-machine
.. _inventory file: http://docs.ansible.com/intro_inventory.html

The inventory file can look something like this:

.. code-block:: dosini

    node1 ansible_ssh_hostname=10.10.10.10
    node2 ansible_ssh_hostname=10.10.10.11
    node3 ansible_ssh_hostname=10.10.10.12
    node4 ansible_ssh_hostname=10.10.10.13
    node5 ansible_ssh_hostname=10.10.10.14
    node6 ansible_ssh_hostname=10.10.10.15
    zk1 ansible_ssh_hostname=10.10.10.16
    zk2 ansible_ssh_hostname=10.10.10.17
    zk3 ansible_ssh_hostname=10.10.10.18

    [consul_server]
    node[1:6]

    [dc1]
    node[1:3]

    [dc2]
    node[4:6]

    [zookeeper_servers:vars]
    service_tags=ensemble1

    [zookeeper_servers]
    zk1 zk_id=1
    zk2 zk_id=2
    zk3 zk_id=3

    [mesos_leaders]
    node1 mesos_mode=leader
    node2 mesos_mode=leader
    node3 mesos_mode=leader

    [mesos_followers]
    node[4:6]

    [marathon_servers]
    node[1:3]

This sets six nodes to be in the ``consul_server`` group, with the
first three communicating in the ``dc1`` group, and the second three
in the ``dc2`` group. It also assigns three zookeeper servers and a
set :data:`zk_id` for each (which you **must do**), and sets up Mesos
leaders and followers. This inventory can also be `generated
dynamically`_.

Once you have your inventory file in place, test your connections
using the command ``ansible all -i /path/to/your/inventory -m
ping``. All your nodes should respond with "pong". If they don't,
check your connection by adding ``-vvvv`` for verbose SSH debugging
and try again to view the errors in more detail.

Once you're able to connect to your nodes, you'll want to use a
`playbook`_ to tell Ansible what to put where. Here's a sample:

.. _playbook: http://docs.ansible.com/playbooks.html

.. code-block:: yaml+jinja

    ---
    - hosts: all
      roles:
        - common
        - docker
        - dnsmasq
    
    - hosts: consul_client
      gather_facts: no
      roles:
        - consul
    
    - hosts: consul_server:&dc1
      gather_facts: no
      serial: 1
      roles:
        - consul
    
    - hosts: consul_server:&dc2
      gather_facts: no
      serial: 1
      roles:
        - consul
    
    - hosts: all
      gather_facts: no
      roles:
        - registrator
    
    - hosts: zookeeper_servers
      gather_facts: no
      roles:
        - zookeeper
    
    - hosts: mesos_leaders
      gather_facts: no
      roles: 
        - mesos
    
    - hosts: mesos_followers
      gather_facts: no
      roles: 
        - mesos

.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
