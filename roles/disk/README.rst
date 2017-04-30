Disk
======

.. versionadded:: 1.3

The disks role simply configures a ``mantldata`` logical volume and allocates
the remainder (by default) of the mantl physical volume to ``/mnt/mantldata``.
This is a good location to use for host-level storage and is used by addons like
Kafka and Elasticsearch (by default).
