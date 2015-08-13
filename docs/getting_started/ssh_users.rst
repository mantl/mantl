Adding SSH Users
================

If you want to add more users to the servers, create a file (e.g. ``users.yml``).
Below is an example. Each public ssh key should be on a single line. The ``users.yml``
file will need to be passed to ``ansible-playbook`` with ``-e @users.yml``.

.. warning:: All users added in this file will have root access via ``sudo``.

.. code-block:: yaml

  ---
  users:
   - name: user1
     enabled: 1
     pubkeys:
       - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABA.....

  - name: user2
      enabled: 1
      pubkeys: 
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAABA......

