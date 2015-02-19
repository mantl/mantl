OpenStack
=========

.. todo:: document network setup

This project provides a number of playbooks to get your hosts created
using OpenStack. You can find them in ``openstack/`` in the main
project directory. To use them you will need the following variables
set:

.. envvar:: OS_AUTH_URL

   Authentication URL, should point to Keystone

.. envvar:: OS_USERNAME

   Your OpenStack username

.. envvar:: OS_PASSWORD

   Your OpenStack password

.. envvar:: OS_TENANT_NAME

   Tenant in which to create instances (alternatively called "project"
   in some older tools)

After setting these, you can provision a new CentOS 7 image with
``openstack/provision-image.yml``, add your SSH key to your tenant
with ``openstack/provision-nova-key.yml``, spin up new instances with
``openstack/provision-hosts.yml``, and destroy them with
``openstack/destroy-hosts.yml``. These playbooks all use the host
variables defined in ``inventory/``

