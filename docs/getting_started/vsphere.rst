VMware vSphere
================

You can bring up VMware vSphere environment using Terraform with third-party vSphere provider.

Prerequisites
---------------

Terraform
^^^^^^^^^^^

Install Terraform according to the `guide <https://www.terraform.io/intro/getting-started/install.html>`_. 

vSphere plugin
^^^^^^^^^^^^^^^^

Download `vSphere plugin <https://github.com/mkuzmin/terraform-vsphere/releases>`_ for Terraform. `Install <https://terraform.io/docs/plugins/basics.html>`_ it, or put into a directory with Terraform binaries or configuration files.
The detailed information about this plugin you can find `here <https://github.com/mkuzmin/terraform-vsphere>`_

VMware template
^^^^^^^^^^^^^^^^^

Create `VMware template <https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vsphere.vm_admin.doc_50%2FGUID-40BC4243-E4FA-4A46-8C8B-F50D92C186ED.html>`_ for microservices cluster. You will able to change CPU and RAM parameters while provisioning a virtual machine from template with Terraform. It's recommended to disable SELinux. Create user and add public RSA keys for SSH into the $HOME/.ssh/authorized_keys.
It is required to have VMware tools in the template, because we need to populate resulting ``.tfstate`` file with IP addresses of provisioned machines.
This configuration was tested on CentOS 7.1 x64. 


Configuring vSphere for Terraform
-----------------------------------

Provider settings
^^^^^^^^^^^^^^^^^^^
``vcenter_server``, ``user`` and ``password`` are the required parameters needed by Terraform to interact with resources in your vSphere.
``insecure_connection`` parameter is reponsible for checking SSL certificates of the vCenter. If you have self-signed certificates it is necessary to set this parameter to ``false``.

.. envvar:: VSPHERE_USER

   The vSphere username with the necessary permissions.
  
.. envvar:: VSPHERE_PASSWORD

   The password of the user.

Basic settings
^^^^^^^^^^^^^^^^

``datacenter`` is the name of datacenter in your vSphere environment. It is required if the vSphere has several datacenters.

``host`` is the hostname or IP address of ESXi host in the selected datacenter.

``pool`` is the name of resource pool in vSphere. It's an optional parameter.

``template`` is the name of a base VM or template you will deploy you machines from. Should include a path in VM folder hierarchy: ``folder/subfolder/vm-name``

``short_name`` is the prefix that will be used for the new virtual machines.

``ssh_user`` is the username for the further service provisioning. This user has to be in the sudoers group with NOPASSWD option.

``ssh_key`` is the path to the SSH private key.


Microservices settings
^^^^^^^^^^^^^^^^^^^^^^^

``control_count`` and ``worker_count`` are the number of nodes for specific roles.

``consul_dc`` the name of datacenter for Consul configuration.

Advanced settings
^^^^^^^^^^^^^^^^^^^

You also can change advanced settings in module file ``terraform/vsphere/main.tf``

``cpus`` is the number of CPU sockets in the new VM. By default the same, as base VM

``memory`` is the RAM size in MB. By default the same, as base VM.

``configuration_parameters`` are the custom parameters, for example specific service ``role``. 

Provisioning
--------------

Once you're all set up with the provider, customize your module, run ``terraform get`` to prepare Terraform to provision your cluster, ``terraform plan`` to see what will be created, and ``terraform apply`` to provision the cluster. At the end of provisioning Terraform will perform commands to change hostnames for correct service work. You can change this behavior in the ``provisioner`` section for each resource in the ``terraform/vsphere/main.tf`` file. 

Afterwards, you can
use the instructions in :doc:`getting started <index>` to install
Mantl on your new cluster. 


