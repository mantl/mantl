OpenStack
=========

.. todo:: document network setup

This project provides a number of playbooks to get your hosts created
using OpenStack. You can find them in ``openstack/`` in the main
project directory.

Before we can build any servers using Ansible, we need to configure authentication.

Configuring OpenStack authentication 
------------------------------------

Because we can deploy to different OpenStack regions, we'll have to use a file that contains unique configurations for each region.

Example files are located in ``inventory/group_vars/dc1`` and ``inventory/group_vars/dc2``

The file looks like this:

.. code::

  os_auth_url:
  os_tenant_name:
  os_tenant_id:
  os_net_id: fd94baf0-b314-453e-9cd6-73c90fc53857
  consul_dc: dc1

In the next sections, we'll explain how to obtain these settings.

Getting OpenStack tenant settings
----------------------------------------
``os_auth_url``, ``os_tenant_name``, and ``os_tenant_id`` is unique for each OpenStack datacenter. You can get these from the OpenStack web console:

1. Log Into the OpenStack web console and in the Manage Compute section, select "Access & Security". 

2. Select the "API Access" tab.

3. Click on the "Download the OpenStack RC File" button. We'll use this file to set up authentication.
4. Download the RC file for each Data Center you want to provision servers in. You may have to log into different OpenStack web consoles.

.. image:: ../_static/openstack_rc.png

Open the file that you just downloaded. We are interested in three of the environment variables that are exported:

.. code::

  export OS_AUTH_URL=https://my.openstack.com:5000/v2.0
  export OS_TENANT_ID=my-long-unique-id
  export OS_TENANT_NAME="my-project"


Update the ``inventory/dc1`` file with these values for the apropriate fields. If you have a second region, update ``inventory/dc2`` with values from the second file.


OpenStack Username/Password
---------------------------


The playbooks get Username/Password information via environment variables:


.. envvar:: OS_USERNAME

   Your OpenStack username

.. envvar:: OS_PASSWORD

   Your OpenStack password

So before running any playbooks, run the following command to to pull in your username password:

.. code::

  source <my_openstack.rc>


After setting these, you can provision a new CentOS 7 image with
``openstack/provision-image.yml``, add your SSH key to your tenant
with ``openstack/provision-nova-key.yml``, spin up new instances with
``openstack/provision-hosts.yml``, and destroy them with
``openstack/destroy-hosts.yml``. These playbooks all use the host
variables defined in ``inventory/``

