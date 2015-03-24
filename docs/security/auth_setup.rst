the auth-setup script
=====================

The ``auth-setup`` script is located in the root of the project. It will set up
authentication and authorization for you, as described in the :doc:`component
documentation <../components/index>`. When components are updated, you can run it
again, as many times as you want. It will only set the variables it needs to.

After you've set up security with the script, you can include it in your
playbook runs by specifying the ``-e`` or ``--extra-vars`` option, like so::

    ansible-playbook site.yml --extra-vars=@security.json
