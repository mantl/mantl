LVM
===

.. versionadded:: 0.5

The lvm role optionally creating LVM Volume Group, specifically:

- Install required software and tools.
- Enable `lvmetad` daemon.
- Create volume group and add provided extra block device to it as physical volume.
- Register fact with name of created volume group.

Variables
---------

.. data :: lvm_volume_group_name

   Volume group name to be created.

   default: ``mantl``

.. data :: lvm_physical_device

   Device name for attach as volume group.

   Default value can vary depending from used cloud.

   - For Openstack: /dev/vdb
   - For GCE: /dev/disk/by-id/google-lvm 
   - For AWS: /dev/xvdh

.. debug_storage_setup:

   Define source of partitioner script. If set to ``True`` then
   ``mantl-storage-setup`` script and associated files deployed from ansible tree,
   otherwise it come with ``mantl-storage-setup`` package from Mantl repository.

   default: ``False``

Facts
-----

.. data :: volume_group_name

   This fact set after volume creation, and used later by docker and glusterfs roles.

   default:  ``None`` (if no LVM used)

