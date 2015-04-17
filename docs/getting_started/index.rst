Getting Started
===============

.. note:: This document assumes you have a `working Ansible
          installation`_. If you don't, install Ansible before
          continuing. This can be done simply by running ``pip install -r
          requirements.txt`` from the root of the project.

The Microservices Infrastructure project uses Ansible to bring up
nodes and clusters. This generally means that you need three things:

 1. hosts to use as the base for your cluster
 2. an `inventory file`_ with the hosts you want to be modified.
 3. a playbook to show which components should go where.

Provisioning Cloud Hosts
------------------------

The playbooks and roles in this project will work on whatever provider
(or metal) you care to spin up, as long as it can run CentOS 7 or
equivalent. However, here are some guides to get started on common
platforms:

.. toctree::
   :maxdepth: 1

   openstack.rst

Setting up Authentication and Authorization
-------------------------------------------

Before you begin, you'll want to run the ``security-setup`` script in the
root directory. This will create and set passwords, authentication, and
certificates. For more information, see the :doc:`security-setup
<../security/security_setup>` documentation.

Deploying software via Ansible
------------------------------

In the following examples, we're going to assume you deployed hosts using
``inventory/1-datacenter``.

First, ping the servers to ensure they are reachable via ssh:

.. code-block:: shell

 ansible all -i inventory/1-datacenter -m ping 

If any servers fail to connect, check your connection by adding ``-vvvv`` 
for verbose SSH debugging and try again to view the errors in more detail.

Next, deploy the software

.. code-block:: shell

  ansible-playbook -i inventory/1-datacenter site.yml

The deployment will probably take a while as all tasks are completed. 


Checking your deployment
------------------------
If the playbooks are successful, you should be able to reach the web
consoles for Mesos, Marathon and Consul.

Here are some links to test on host-01 (make sure host-01 resolves via ``/etc/hosts`` or DNS):

*  `mesos-leader`_ on port 5050
*  `marathon`_ on port 8080
*  `consul`_ on port 8500

.. _marathon: http://host-01:8080
.. _mesos-leader: http://host-01:5050
.. _consul: http://host-01:8500


Customizing your deployment
---------------------------
Below are guides to customizing your host inventory, Ansible playbooks and adding users.

.. toctree::
   :maxdepth: 1

   inventory.rst
   playbook.rst
   ssh_users.rst  
        
.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
.. _inventory file: http://docs.ansible.com/intro_inventory.html
.. _playbook: http://docs.ansible.com/playbooks.html
.. _working Ansible installation: http://docs.ansible.com/intro_installation.html#installing-the-control-machine


Restarting your deployment
--------------------------
To restart your deployment and make sure all components are restarted and working correctly, it is recommended to leverage the
``playbooks/reboot-hosts.yml`` playbook.

.. code-block:: shell 

    ansible-playbook -i inventory/1-datacenter playbooks/reboot-hosts.yml


