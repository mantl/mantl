Adding SSH Users
--------------------
If you wish to add more users to the servers. Update the ``inventory/groups_vars/all/users.yml``` file. Below is an example. Each public ssh key should be on a single line.

.. note:: All users added in this file will have ``sudo`` access to the root account. 

.. code-block:: yaml

  ---
  users:
   - name: user1
     enable: 1
     pubkeys:
       - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABA.....

  - name: user2
      enable: 1
      pubkeys: 
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAABA......

