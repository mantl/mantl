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
   gce.rst
   aws.rst
   digitalocean.rst
   vsphere.rst
   softlayer.rst

Setting up DNS
--------------

You can set up your DNS records with Terraform:

.. toctree::
   :maxdepth: 2

   dns.rst


Setting up Authentication and Authorization
-------------------------------------------

Before you begin, you'll want to run the ``security-setup`` script in the
root directory. This will create and set passwords, authentication, and
certificates. For more information, see the :doc:`security-setup
<../security/security_setup>` documentation.

Deploying software via Ansible
------------------------------

.. note:: Ansible requres a Python 2 binary. If yours is not at /usr/bin/python,
          please view the `Ansible FAQ <http://docs.ansible.com/faq.html>`_. You
          can add an extra variable to the following commands, e.g.
          ``ansible -e ansible_python_interpreter=/path/to/python2``.

In the following examples, we're going to assume you deployed hosts using
Terraform. This project ships with a dynamic inventory file to read Terraform
``.tfstate`` files. To use it, just use the ``-i
plugins/inventory/terraform.py`` argument of ``ansible`` or
``ansible-playbook``.

First, ping the servers to ensure they are reachable via ssh:

.. code-block:: shell

  ansible all -i plugins/inventory/terraform.py -m ping 

If any servers fail to connect, check your connection by adding ``-vvvv``
for verbose SSH debugging and try again to view the errors in more detail.

Next, deploy the software. First, you'll need to customize a playbook. A sample
can be found at ``terraform.sample.yml`` in the root directory, you can find
more about customizing this at :doc:`playbook`. The main change you'll want
to make is changing ``consul_acl_datacenter`` to your preferred ACL datacenter.
If you only have one datacenter, you can remove this variable. Next, assuming
you've placed the filled-out template at ``terraform.yml``:

.. code-block:: shell

  ansible-playbook -i plugins/inventory/terraform.py -e @security.yml terraform.yml

The deployment will probably take a while as all tasks are completed.

Checking your deployment
------------------------

If the playbooks are successful, you should be able to reach the web consoles
for Mesos (on control nodes port 5050), Marathon (port 8080) and Consul (port
8500.)

Customizing your deployment
---------------------------

Below are guides customizing your deployment:

.. toctree::
   :maxdepth: 1

   ssh_users.rst  
   playbook.rst
   dockerfile.rst

.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
.. _inventory file: http://docs.ansible.com/intro_inventory.html
.. _playbook: http://docs.ansible.com/playbooks.html
.. _working Ansible installation: http://docs.ansible.com/intro_installation.html#installing-the-control-machine

Restarting your deployment
--------------------------

To restart your deployment and make sure all components are restarted and
working correctly, use the ``playbooks/reboot-hosts.yml`` playbook.

.. code-block:: shell

    ansible-playbook playbooks/reboot-hosts.yml

Using a Docker Container to Provision your Cluster
---------------------------------------------------

You can also provision your cluster by running a docker container. See :doc:`dockerfile` for more information.
