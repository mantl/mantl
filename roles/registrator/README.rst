.. versionadded:: 0.1

`Registrator <https://github.com/progrium/registrator/>`_ watches for
new docker containers and creates entries for them in :doc:`consul`,
making them discoverable.

Variables
---------

.. data:: registrator_image

   default: ``progrium/registrator``
          
.. data:: registrator_image_tag

   default: ``latest``

.. _registrator-example-playbook:

Example Playbook
----------------

.. code-block:: yaml+jinja

    ---
    # this should be the set of all servers that you plan to run
    # Docker containers that need to be discoverable.
    - hosts: all
      roles:
        - registrator
