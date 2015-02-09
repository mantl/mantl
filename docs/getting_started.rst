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

    node0 ansible_ssh_hostname=10.10.10.10
    node1 ansible_ssh_hostname=10.10.10.11
    node2 ansible_ssh_hostname=10.10.10.12
    node3 ansible_ssh_hostname=10.10.10.13
    node4 ansible_ssh_hostname=10.10.10.14
    node5 ansible_ssh_hostname=10.10.10.15

    [consul_server]
    node[0:5]

    [dc1]
    node[0:2]

    [dc2]
    node[3:5]

This sets all nodes to be in the ``consul_server`` group, with the
first three communicating in the ``dc1`` group, and the second three
in the ``dc2`` group. This inventory can also be `generated dynamically`_.

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
      # TODO: vars to set consul in client mode
    
    - hosts: consul_server:&dc1
      gather_facts: no
      serial: 1
      roles:
        - consul
      # TODO: vars to set consul dc1
    
    - hosts: consul_server:&dc2
      gather_facts: no
      serial: 1
      roles:
        - consul
      # TODO: vars to set consul dc2
    
    # TODO: note about this
    #- include: playbooks/consul-join-wan.yml
    
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
      # TODO: mesos mode
    
    - hosts: mesos_followers
      gather_facts: no
      roles: 
        - mesos
      # TODO: mesos mode

.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
