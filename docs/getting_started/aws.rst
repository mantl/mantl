Amazon Web Services
=====================

.. versionadded:: 0.3

As of microservices-infrastructure 0.3 you can bring up Amazon Web Services
environments using Terraform. microservices-infrastructure uses Terraform to
provision hosts in OpenStack. You can `download Terraform from terraform.io
<http://www.terraform.io/downloads.html>`_.

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

Creating an IAM User
^^^^^^^^^^^^^^^^^^^^^

Before running Terraform, we need to supply it with valid AWS credentials. While
you could use the credentials for your AWS root account, it is `not recommended
<http://docs.aws.amazon.com/general/latest/gr/aws-access-keys-best-practices.html>`_.
In this section, we'll cover creating an `IAM User
<http://docs.aws.amazon.com/IAM/latest/UserGuide/Using_WorkingWithGroupsAndUsers.html>`_
that has the necessary permissions to build your cluster with Terraform.

.. note:: You'll need to have an existing AWS account with sufficient IAM
          permissions in order to follow along. If not, ask your account owner
          to perform this step for you.

First, sign in to your AWS Console and navigate to the `Identity & Access
Management (IAM) <https://console.aws.amazon.com/iam/home>`_ service.

.. image:: /_static/aws_iam.png
   :alt: The AWS Identity & Access Management Service

Next, navigate to the "Users" screen and click the "Create New Users" button.

.. image:: /_static/aws_iam_users.png
   :alt: Create IAM User

You will be given the opportunity to create 5 different users on the next
screen. For our purposes, we are just going to create one:
"microservices-infrastructure". Make sure that you leave the "Generate an access
key for each user" option checked and click the "Create" button.

.. image:: /_static/aws_iam_create_user.png
   :alt: IAM Create User

On the next screen, you will be able to view and download your new Access Key ID
and Secret Access Key. Make sure you capture these values in a safe and secure
place as you will need them in the next section. You won't be able to retrieve
your secret key later (although you can generate a new one, if needed).

The next step is to grant permissions to your new IAM user. Navigate back to the
"Users" section and then click on the user name you just created. On the next
screen, you will be able to manage the groups your user belongs to and to grant
the permissions to view and modify AWS resources. For this example, we will not
be using groups but that would be an option if you wanted to create multiple IAM
users with the same permissions. We are going to keep it simple and use a
managed policy to grant the necessary permissions to our IAM user.

Click the "Attach Policy" button.

.. image:: /_static/aws_iam_attach_policy.png
   :alt: IAM User attach policy

On the "Attach Policy" screen you will see a long list of pre-built permissions
policies. You can either scroll through the list or use the search filter to
find the policy named "AmazonEC2FullAccess". Check the box next to that policy
and click the "Attach Policy" button.

.. image:: /_static/aws_ec2fullaccess.png
   :alt: IAM AmazonEC2FullAccess Managed Policy

That's it. At this point, your IAM user has sufficient privileges to provision
your cluster with Terraform.

.. note:: Technically the "AmazonEC2FullAccess" managed policy grants more
          permissions than are actually needed. If you are interested in
          configuring your IAM user with the minimum set of permissions to
          provision a cluster, you can see the custom policy included at the
          bottom of this document.

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

Custom IAM Policy
^^^^^^^^^^^^^^^^^^

At the time of this writing, the following IAM policy grants the minimal
permissions needed to provision an AWS cluster with Terraform.

.. literalinclude:: /_static/aws_custom_iam_policy.json
   :language: javascript
