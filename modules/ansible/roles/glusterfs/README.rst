GlusterFS
=========

.. versionadded:: 0.4

`Gluster <http://www.gluster.org/>`_ implements a distributed filesystem. It is
used for container volume management and syncing around the cluster.

Current Version: 3.7.6

Installation
------------

As of 0.5.1, GlusterFS is distributed as an addon for Mantl. After a successful
initial run (from your customized ``sample.yml``), install it with
``ansible-playbook -e @security.yml addons/glusterfs.yml``.

Restarting
----------

There is a bug with the current implementation where the glusterd servers will
not come up after a restart, but they'll be fine to start once the restart is
complete. To do this after a restart, run::

    ansible -m command -a 'sudo systemctl start glusterd' role=control

You will also need to mount the disks after this operation::

    ansible -m command -a 'sudo mount -a' role=control

Use with Docker
---------------

Any Docker volume should be able to access data inside the
``/mnt/container-volumes`` partition. Because of SELinux, the volume label needs
to be updated within the container. You can use the ``z`` flag to do this, as in
this example which will open up a prompt in a container where the volume is
mounted properly at ``/data``::

    docker run --rm -it -v /mnt/container-volumes/test:/data:z gliderlabs/alpine /bin/sh

Cloud Configuration
-------------------

On Google Compute Engine, Amazon Web Services, and OpenStack the
Mantl Terraform modules will create an external volume.
By default, this volume will be 100gb, but you can change this with the
Terraform ``glusterfs_volume_size`` variable. The attached disk will be
formatted as an XFS volume and mounted on the control nodes.

Variables
---------

.. data:: glusterfs_version

   The version of GlusterFS to download

   default: ``3.7.6``

.. data:: glusterfs_mode

   The mode that GlusterFS will be configured in. Valid values: "server" and
   "client".

   default: ``client``

.. data:: glusterfs_replication

   The amount of replication to use for new volumes. Should be a factor of the
   number of nodes in the server group

   default: the number of control nodes present in the server group

.. data:: glusterfs_server_group

   A selector for a group to use as Gluster servers.

   default: ``role=control``

.. data:: glusterfs_brick_mount

   Where the Gluster external disk will be mounted on supported cloud providers.

   default: ``/mnt/glusterfs``

.. data:: glusterfs_brick_device

   Automatically calculated depending on which cloud provider you are using.
   This should only be changed if you're adding support for a new cloud provider
   or know very well where your volume is going to be located.

   default: automatically generated

.. data:: glusterfs_volume_force

   Whether the glusterfs volume should be force-created (that is, created with
   storage on the root partition.) This is true when not using a cloud provider
   that supports external block storage.

   default: automatically generated "yes" or "no"

.. data:: glusterfs_brick_location

   The area in the filesystem to store bricks. It defaults to the value of
   ``glusterfs_brick_mount`` if an external disk is mounted, and
   ``/etc/glusterfs/data`` otherwise.

   default: automatically generated

.. data:: gluserfs_volumes

   A list of names and mounts for volumes. The default looks like this::

       glusterfs_volumes:
         - name: container-volumes
           mount: /mnt/container-volumes

   If you need to add any more volumes, be sure to include the
   ``container-volumes`` mount in the list, or that volume will not work on new
   servers.
