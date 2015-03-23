the auth-setup script
=====================

The ``auth-setup`` script is located in the root of the project. It will set up
authentication and authorization for you, as described in the :doc:`component
documentation <../components/index>`. When components are updated, you can run it
again, as many times as you want. It will only set the variables it needs to.

After you've set up security with the script, you can include it in your
playbook runs by specifying the ``-e`` or ``--extra-vars`` option, like so::

    ansible-playbook site.yml --extra-vars=@security.json

Here's a sample output of the script::

    ================ Consul ================
    ----> gossip key
    set gossip key
    ----> master acl token
    set acl master token
    =============== Marathon ===============
    ----> marathon framework authentication
    set marathon framework secret
    ============== Zookeeper ===============
    ----> super user auth
    set zk super user secret
    ----> mesos user auth
    set zk mesos user secret
    ----> marathon user auth
    set zk marathon user secret
    ----> turn on consul ssl
    configuring consul ssl defaults
    ================ Mesos =================
    ----> framework auth
    set auth for Marathon
    enabled framework auth
    ----> follower auth
    added follower secret to leader config
    enabled follower auth
    ========================================
    Wrote security settings to security.json. Include them in your Ansible run like this:

        ansible-playbook -i your-playbook.yml -e @security.json
