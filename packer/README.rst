Packer
======

The Mantl Vagrant image is built using `Packer
<https://packer.io>`_. To build it for yourself, run ``packer build
packer/vagrant.json``. If you want to build with `Atlas
<https://atlas.hashicorp.com>`_, use ``packer push packer/vagrant.json``.

The image is created using the existing Ansible playbooks, but run in a limited
mode (specifically, with only tasks tagged ``bootstrap``.) Aside from Ansible,
there are a number of shell scripts that are run. Here's what they do:

``ansible.sh``
--------------

Installs Ansible from EPEL

``vagrant.sh``
--------------

Downloads the default insecure public key from the `Vagrant Github repostory
<https://github.com/mitchellh/vagrant>`_ to allow the ``vagrant`` user to log
in.

``vbox.sh``
-----------

Installs the `VirtualBox Guest Additions
<http://www.virtualbox.org/manual/ch04.html>`_ so that folder syncing can work
inside Vagrant.

``cleanup.sh``
--------------

Performs cleanup tasks after installation is complete to limit image size when
distributed. Specifically:

 - Remove Ansible and cached yum information
 - Remove persistent network information
 - Remove temporary files, including ``/tmp/*`` and files under the home
   directory and log directories.
 - Zero out all empty disk space and sync
