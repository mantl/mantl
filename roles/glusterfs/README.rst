GlusterFS
=========

.. versionadded:: 0.4

`Gluster <http://www.gluster.org/>`_ implements a distributed filesystem. It is
used for container volume management and syncing around the cluster.

Current Version: 3.7.3

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
microservices-infrastructure Terraform modules will create an external volume.
By default, this volume will be 100gb, but you can change this with the
Terraform ``glusterfs_volume_size`` variable. The attached disk will be
formatted as an XFS volume and mounted on the control nodes.

Variables
---------

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

.. data:: glusterfs_container_data_name

   The name of the Gluster container in which you plan to store container
   volumes.

   default: ``container-volumes``

.. data:: glusterfs_container_data_mount

   Where to mount the container data volume. Defaults to the name of the volume
   under ``/mnt/``

   default: automatically generated
