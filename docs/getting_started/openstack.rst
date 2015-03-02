OpenStack
=========

.. todo:: document network setup

This project provides a number of playbooks to get your hosts created
using OpenStack. You can find them in ``openstack/`` in the main
project directory. 
set:

Configuring OpenStack authentication 
------------------------------------

Because we can deploy to two different OpenStack DCs, we'll have to use a file that contains configuration data for each data center. 

Example files are located in ``inventory/group_vars/dc1`` and ``inventory/group_vars/dc2``

The file looks like this:

.. code:: shell
  os_auth_url:
  os_tenant_name:
  os_tenant_id:
  os_net_id: fd94baf0-b314-453e-9cd6-73c90fc53857
  consul_dc: dc1

In the next section, we'll explain how to obtain these settings.

Getting OpenStack authenticaton settings
----------------------------------------

1. Log Into the OpenStack Web Console and in the Manage Compute section, select "Access & Security". 

2. Select API Access

3. Download the OpenStack RC file. We'll use this file to set up authentication.
4. Download the RC file for each Data Center you want to provision servers in.

.. image:: ../_static/openstack_rc.png



The playbooks get authentication information via environment variables:


.. envvar:: OS_USERNAME

   Your OpenStack username

.. envvar:: OS_PASSWORD

   Your OpenStack password

After setting these, you can provision a new CentOS 7 image with
``openstack/provision-image.yml``, add your SSH key to your tenant
with ``openstack/provision-nova-key.yml``, spin up new instances with
``openstack/provision-hosts.yml``, and destroy them with
``openstack/destroy-hosts.yml``. These playbooks all use the host
variables defined in ``inventory/``

