Google Compute Engine
=====================

.. versionadded:: 0.3

As of Mantl 0.3 you can bring up Google Compute Engine environments using
Terraform. microservices-infrastructure uses Terraform to provision hosts. You
can `download Terraform from terraform.io
<http://www.terraform.io/downloads.html>`_.

Configuring Google Compute Engine for Terraform
-----------------------------------------------

Before we can build any servers using Terraform and Ansible, we need to
configure authentication. We'll be filling in the authentication variables for
the template located at ``terraform/gce.sample.tf``. It looks like this:

.. this is highlighted as javascript for convenience, but obviously that's not
   the *real* language.
.. literalinclude:: ../../terraform/gce.sample.tf
   :language: javascript

Copy that file in it's entirety to the root of the project to start
customization. In the next sections, we'll explain how to obtain these settings.

Basic Settings
^^^^^^^^^^^^^^

``project``, ``region`` and ``zone`` are unique values for each project in Google Compute
Engine. ``project`` is available from the project overview page (use the Project
ID not the Project Name.) You can select which region and zone you want to use from any of the GCE zones (see
the image below) If you're in the United States, `us-central1` and `us-central1-a` are a good choice.
If you're in Europe, `europe-west1` and `europe-west1-b` might be your best bets. If you haven't
previously activated Compute Engine for your project, this is a good time to do
it. 

.. image:: /_static/gce_zones.png
   :alt: The GCE zones available at Product and Services menu -> Compute Engine -> Zones in their
         interface.

If you don't want to commit these values in a file, you can source them from the
environment instead:

.. envvar:: GOOGLE_PROJECT

   The ID of a project to apply resources to.

.. envvar:: GOOGLE_REGION

   The region to operate under.

``account.json``
^^^^^^^^^^^^^^^^

Terraform also needs service account to be able to create and manage
resources in your project. You can create one by going to the "Credentials"
screen under "API Manager" in the GCP Product and Services menu.
Service accounts are created under New credentials -> Service account key.

.. note:: You'll need to be an account owner to create this file - if you're
          not, ask your account owner to do this step for you.

.. image:: /_static/gce_service_account.png
   :alt: The GCE UI for creating a service account.

You will either need to create an new service account or use an exisiting one. For this example we
created one called ``terraform``. 

.. image:: /_static/gce_service_account_dialogue.png
   :alt: The GCE dialogue for creating a service account. "Service account" is
         selected.

Once you've created your account, your browser will download a JSON file
containing the credentials. Point ``credentials`` to the path you decide to
store that file in. If you're running Terraform from a Google Compute instance
with an associated service account, you may leave the ``credentials`` parameter
blank.


Provisioning
------------

Once you're all set up with the provider, customize your modules (for
``control_count``, ``edge_count`` and ``worker_count``). Make sure your local 
ssh-agent is running and your ssh key has been added, this is requrired
by the Terraform provisioner. Run ``ssh-add ~/.ssh/id_rsa`` to add your ssh key.
Run ``terraform get`` to prepare Terraform to provision your cluster, ``terraform plan`` to see what will be
created, and ``terraform apply`` to provision the cluster. Afterwards, you can
use the instructions in :doc:`getting started <index>` to install
microservices-infrastructure on your new cluster.

.. note:: If you get the below when running terraform plan or apply, 
  you will need to add : ``account_file = ""`` to the provider section of your gce.tf file.::
  
    provider.google.account_file
    Enter a value:
   
  
  This is a know bug in older version of terraform.

Configuring DNS with Google Cloud DNS
-------------------------------------

In addition to the :doc:`normal provider variables <dns>`, you will need to
specify the ``managed_zone`` parameter. If you haven't set up a managed zone for
the domain you're using, you can do that with Terraform as well, just add this
extra snippet in your .tf file:

.. code-block:: javascript

   resource "google_dns_managed_zone" "managed-zone" {
     name = "my-managed-zone"
     dns_name = "example.com."
     description "Managed zone for example.com."
   }
