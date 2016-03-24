Using the Dockerfile
===========================

.. versionadded:: 0.3.1

.. note:: Please review the :doc:`getting started guide <./index>` for more
          detailed information about setting up a cluster.

Setup
--------

1. Before you begin, it is recommended that you run the :doc:`security-setup
   script <../security/security_setup>` to configure authentication and
   authorization for the various components.

2. Next, you will need to setup a Terraform template (``*.tf`` file) in the root
   directory for the cloud provider of your choices. See the following links for
   more information:

   .. toctree::
      :maxdepth: 1

      openstack.rst
      gce.rst
      aws.rst

3. Finally, you need to create a custom ansible playbook for your cluster. You
   can copy `sample.yml` to `mantl.yml` in your root directory to
   get started.

Building a Docker Image
-------------------------

Now you'll be able to build a docker image from the `Dockerfile`:

``docker build -t mi .``

In this example, we are tagging the image with the name `mi` which we will be
using later in this guide.

Running a Container
---------------------

Now we can run a container from our image to provision a new cluster. Before we
do that, there are a couple of things to understand.

By default, our Terraform templates are configured with the assumption that you
have an SSH public key called ``id_rsa.pub`` in the ``.ssh`` folder of your home
directory (along with a corresponding private key). Terraform uses this to
authorize your key on the cluster nodes that it creates. This provides you with
SSH access to the nodes which is required for the subsequent Ansible
provisioning. The simplest way to handle this when running from a Docker
container is to mount your ``~/.ssh`` folder in the container. You will see an
example of this later in the document.

Another important thing to understand is how Terraform manages `state
<https://terraform.io/docs/state/index.html>`_. Terraform uses a `JSON`
formatted file to store the state of your managed infrastructure. This state
file is important as it will allow you to use Terraform to plan, inspect, modify
and destroy resources in your infrastructure. By default, Terraform writes state
to a file called ``terraform.tfstate`` in the same directory where you launched
Terraform. Our ``Dockerfile`` is configured to store the state in a Docker
volume called ``/state``. This will allow you to mount that volume so that you
can easily access the ``terraform.tfstate`` file to use for future Terraform
runs.

Now we can use this information to run our container:

``docker run -it -v ~/.ssh/:/ssh/ -v $PWD:/state mi``

As discussed above we are launching a container from the ``mi`` image we created
earlier, while mounting our local ``~/.ssh/`` to ``/ssh`` in the container, and
our current directory to the container's ``/state``. Therefore, the
``terraform.tfstate`` files will be accessible from our local host directory
after the run. Note that we are also allocating a TTY for the container process
(using ``-it``) so that we can enter our SSH key passphrase if necessary.

The container should launch and provision the cluster using the ``security.yml``,
Terraform template, and custom playbook that you configured in the Setup above.

.. note:: If you have customized your Terraform template to use a different SSH
          public key than the default ``~/.ssh/id_rsa.pub``, you can specify the
          corresponding private key as an environment variable (``SSH_KEY``)
          when running the container. For example:

          ``docker run -it -e SSH_KEY=/root/.ssh/otherpvtkey -v ~/.ssh/:/ssh/ -v $PWD:/state mi``
