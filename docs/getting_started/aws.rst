Amazon Web Services
=====================

.. versionadded:: 0.3

As of microservices-infrastructure 0.3 you can bring up Amazon Web Services
environments using Terraform.

Configuring Amazon Web Services for Terraform
-----------------------------------------------

Before we can build any servers using Terraform and Ansible, we need to
configure authentication. We'll be filling in the authentication variables for
the template located at ``terraform/aws.sample.tf``. It looks like this:

.. this is highlighted as javascript for convenience, but obviously that's not
   the *real* language.
.. literalinclude:: ../../terraform/aws.sample.tf
   :language: javascript

Copy that file in it's entirety to the root of the project to start
customization. In the next sections, we'll describe the settings that you need
to configure.

Provider Settings
^^^^^^^^^^^^^^^^^^

``access_key`` and ``secret_key`` are the required credentials needed by
Terraform to interact with resources in your AWS account. AWS credentials can be
retrieved when creating a new account or IAM user. New keys can be generated and
retrieved by managing Access Keys in the IAM Web Console. If you don't want to
commit these values in a file, you can source them from the environment instead:

.. envvar:: AWS_ACCESS_KEY_ID

   The AWS Access Key for a valid AWS account or IAM user with the necessary
   permissions.

.. envvar:: AWS_SECRET_ACCESS_KEY

   The AWS secret key.

.. note:: As a `best practice <http://docs.aws.amazon.com/general/latest/gr/aws-access-keys-best-practices.html>`_, it is preferred that you use credentials for an
          IAM user with appropriate permissions rather than using root account
          credentials.

``region`` is the AWS `region
<http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html>`_
where your cluster will be provisioned. As an alternative to specifying
``region`` in the file, it can be read from the environment:

.. envvar:: AWS_DEFAULT_REGION

   The AWS region in which to provision cluster instances.

Basic Settings
^^^^^^^^^^^^^^^

``availability_zone`` is the name of the `availability zone
<http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html>`_
within the ``region`` where your cluster resources will be provisioned.

``source_ami`` is the EC2 AMI to use for your cluster instances. This must be an
AMI id that is available in the ``region`` your specified.

``ssh_username`` is the default user name for SSH access to your cluster hosts.
This value will be dependent on the ``source_ami`` that you use. Common values
are ``centos`` or ``ec2-user``.

``control_type`` and ``worker_type`` are used to specify the EC2 instance type
for your control nodes and worker nodes and they must be compatible with the
``source_ami`` you have specified.

Provisioning
------------

Once you're all set up with the provider, customize your modules (for
``control_count`` and ``worker_count``), run ``terraform get`` to prepare
Terraform to provision your cluster, ``terraform plan`` to see what will be
created, and ``terraform apply`` to provision the cluster. Afterwards, you can
use the instructions in :doc:`getting started <index>` to install
microservices-infrastructure on your new cluster.
