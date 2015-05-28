OpenStack
=========

This project provides a number of playbooks designed for doing host maintenance
tasks on OpenStack hosts. You can find them in ``openstack/`` in the main
project directory.

Configuring OpenStack authentication 
------------------------------------

Before we can build any servers using Terraform and Ansible, we need to
configure authentication. We'll be filling in the authentication variables for
the template located at ``terraform/openstack.sample.tf``. It looks like this:

.. this is highlighted as javascript for convenience, but obviously that's not
   the *real* language.
.. literalinclude:: ../../terraform/openstack.sample.tf
   :language: javascript

You can use that file as a base for further customization. For example, you can
change the names of the modules to be specific to your environment. While we
will explore the authentication variables in the next sections, you will need to
provide the ``region``, ``flavor_name``, and other such variables yourself.

Getting OpenStack tenant settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``auth_url``, ``tenant_name``, and ``tenant_id`` are unique for each OpenStack
datacenter. You can get these from the OpenStack web console:

1. Log Into the OpenStack web console and in the Manage Compute section, select
   "Access & Security".
2. Select the "API Access" tab.
3. Click on the "Download the OpenStack RC File" button. We'll use this file to
   set up authentication.
4. Download the RC file for each Data Center you want to provision servers in.
   You may have to log into different OpenStack web consoles.

.. image:: _static/openstack_rc.png

Open the file that you just downloaded. We are interested in three of the
environment variables that are exported:

.. code-block:: shell

  export OS_AUTH_URL=https://my.openstack.com:5000/v2.0
  export OS_TENANT_ID=my-long-unique-id
  export OS_TENANT_NAME="my-project"

Update your Terraform file with these values for the appropriate fields, and
save the downloaded file for using the maintenance playbooks (you'll just need
to source the environment variables into your shell.)

OpenStack Username/Password
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The playbooks get Username/Password information via environment variables:

.. envvar:: OS_USERNAME

   Your OpenStack username

.. envvar:: OS_PASSWORD

   Your OpenStack password

Before running any playbooks, run the following command to to pull in your
username and password for Ansible to use, changing the file name and location to
the location of your OpenStack RC file:

.. code-block:: shell

  source ~/Downloads/my-project.rc

.. note:: The default OpenStack RC file will prompt for your password in order
          to set OS_PASSWORD.

Once you're all set up there, run ``terraform get`` to prepare Terraform to
provision your cluster, ``terraform plan`` to see what will be created, and
``terraform apply`` to provision the cluster. Afterwards, you can use the
instructions in :doc:`getting started <index>` to install
microservices-infrastructure on your new cluster.
