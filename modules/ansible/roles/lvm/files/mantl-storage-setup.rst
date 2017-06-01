mantl-storage-setup script
==========================

Is a new partitioner solution for Mantl.

Order of execution
------------------

All configuration rules reside in ``/etc/mantl/filesystems.d``, and processed
in alphabetical order. Sections in ``*.conf`` looks like ``action:name`` files
processed in following order (name part using only for sorting/ordering):

  - group -- create volume group.
  - thin -- set up thin pool provider for docker.
  - volume -- set up logical volume with name ``name``
  - filesystem -- format filesystem and add ``.mount`` unit into  ``systemd``.
  - write -- action to write one-liner configs.

``group`` module
----------------

Most of options of ``group`` module is a projection of ``lvcreate``/``pvcreate`` parameters.

.. data :: name

  Name of volume group to create.

.. data :: devices

  List of devices to build volume group
  (refer to ``LVM`` docs for details)

``thin` module
--------------

.. data :: group

  Name of volume group, where to create pool.

.. data :: pool

  Name of pool.

  Default: ``docker``  (this default value to compatible to ``docker-storage-setup``,
  and should be untouched if you upgrade from ``Mantl`` 0.5.1)

.. data :: size

  Size of pool.

.. data :: chunk_size

  Chunk size (see LVM docs for details)

  Default: not specified

.. data :: extra_docker_params

  Extra parameters, to insert to docker configuration.


``volume`` module
-----------------

Create logical volume.

.. data :: group

  Name of volume group, where to create new volume

.. data :: volume

   Name of volume to create.

.. data :: size

   Size of volume, in format acceptable by ``LVM`` tools.

``filesystem`` module
---------------------

Format filesystem, if it not formatted yet.

.. data :: dev

  Block device to format.

  Example:  ``/dev/mantl/glusterfs``

.. data :: fstype

  Filesystem type (as mkfs  ``-t`` parameter)

  Example: ``xfs``

.. data :: mount

  Mountpount.

  Example: ``/mnt/data``

.. data :: wanted_by

  List of units, who wants this mount (In systemd ``WantedBy=`` format)

  Example: docker.service

.. data :: required_by

  List of units, who wants this mount (In systemd ``RequiredBy=`` format)

  Example: docker.service

``write`` module
----------------

  This module used internally by mantl.

.. data :: filename

  Name of file to write

.. data :: content

  Data to write

.. data :: crlf

  Force write of trailing ``\n``

  Default: False
