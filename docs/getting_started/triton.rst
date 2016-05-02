Triton
======

.. versionadded:: 1.1

As of Mantl 1.1 you can bring a Mantl cluster up on Joyent's Triton. Please be
sure to use at least Terraform 0.6.15: the first version with the required
resources.

Configuring Triton for Terraform
--------------------------------

Before we can build any servers using Terraform and Ansible, we need to
configure authentication. We'll be filling in the authentication variables for
the template located at ``terraform/triton.sample.tf``. The beginning of it
looks like this:

.. code-block:: json

   # this sample assumes that you have `SDC_ACCOUNT`, `SDC_KEY_MATERIAL`,
   # `SDC_KEY_ID`, and `SDC_URL` in your environment from (for example) using the
   # Triton command-line utilities. If you don't, set `account`, `key_material`,
   # `key_id`, and `url` in the provider below
   provider "triton" {}

   variable key_path { default = "~/.ssh/id_rsa.pub" }

Copy ``terraform/triton.sample.tf`` in it's entierty to the root of the project
as ``triton.tf`` to start customization. In the next section, we'll explain how
to obtain the settings mentioned above.

Basic Settings
^^^^^^^^^^^^^^

First, we'll need an account. This is the username you use to log into Triton.
You can create an account at `joyent.com <https://www.joyent.com>`_; refer to
their `getting started documentation
<https://docs.joyent.com/public-cloud/getting-started>`_ for more information.
Use the ``SDC_ACCOUNT`` environment variable, or set ``account`` in the provider
(see sample below.)

.. note::

   new Joyent accounts may be subject to provisioning limits. `Contact Joyent
   support <https://docs.joyent.com/public-cloud/getting-started/limits>`_ to
   have those limits raised.

We'll also need your key material and ID. Key material is the material of the
public key used to authenticate requests. You can set ``SDC_KEY_MATERIAL`` with
this info, or use Terraform's ``file`` interpolation, shown below. They key ID
is displayed in your Triton account page, but you can obtain it by running
``ssh-keygen -l -E md5 -f /path/to/your/key/id_rsa.pub``. Set this as ``key_id``
or ``SDC_KEY_ID`` in the environment.

Last, you'll need to specify the datacenter you want to operate in (key:
``url``.) The default is ``us-east-1``, and the general format is
``https://{datacenter-slug}.api.joyentcloud.com``. If unset, this will be pulled
from ``SDC_URL``. You can select from any of `Joyent's public data centers
<https://docs.joyent.com/public-cloud/data-centers>`_, or enter a custom URL for
`a private data center <https://github.com/joyent/sdc>`_.

Finally, here's an example with the variables set:

.. code-block:: json

   provider "triton" {
       account      = "AccountName"
       key_material = "${file("~/.ssh/id_rsa.pub")}"
       key_id       = "25:d4:a9:fe:ef:e6:c0:bf:b4:4b:4b:d4:a8:8f:01:0f"

       # specify the datacenter by giving the API URL
       url = "https://us-east-1.api.joyentcloud.com"
   }

Provisioning
------------

Once your provider is set up, customize your modules (mainly for the variables
ending in ``_count`` to control scaling.) Run ``terraform get`` to prepare the
modules, ``terraform plan`` to see what will be created, and ``terraform apply``
to provision the cluster. Afterwards, you can use the instructions in
:doc:`getting started <index>` to install Mantl on your new cluster.

Configuring DNS
---------------

You can set up your DNS records with Terraform:

.. toctree::
   :maxdepth: 1

   dns.rst
