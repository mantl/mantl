Custom Playbook
---------------
The default site.yml `playbook`_ should be used to start. 

Below are some examples of creating a custom playbook. 

.. note:: In the Mesos plays we're setting some group variables in the
          playbook instead of the inventory. This can be useful when
          your inventory is `generated dynamically`_. It is typically
          best to keep your variables all in one place, so consider
          this for demonstration purposes only.

.. code-block:: yaml+jinja

    ---
    - hosts: all
      roles:
        - common
        - docker
        - dnsmasq
    
    # this syntax essentially means "take all the servers in dc1 which
    # are also in consul_servers"
    # see: http://docs.ansible.com/intro_patterns.html
    - hosts: dc_tx1:&consul_servers
      # to speed things up we turn off gather_facts after we've
      # already done it on the host.
      gather_facts: no
      # consul servers should be updated only a few at a time so that
      # the cluster doesn't lose quorum. We've set it to 1 here because
      # that's the maxiumum you can lose at once in a 3-node cluster.
      serial: 1
      roles:
        - consul
    
    # again, we don't have any hosts in ny1, so this is just how it
    # would run if we *did*.
    - hosts: ny1:&consul_servers
      gather_facts: no
      serial: 1
      roles:
        - consul
    
    # remember that zk_id and other ZooKeeper variables are set in our
    # inventory in this case, so we don't need to define them in the
    # playbook
    - hosts: zookeeper_servers
      gather_facts: no
      roles:
        - zookeeper
    
    - hosts: mesos_leaders
      gather_facts: no
      roles: 
        # here we're providing the value of mesos_mode. It will only
        # be visible within the role.
        - mesos
          mesos_mode: leader
        - marathon
    
    - hosts: mesos_followers
      gather_facts: no
      roles: 
        - mesos
          mesos_mode: follower

Run this playbook with ``ansible-playbook -i /path/to/your/inventory
/path/to/your/playbook.yml``. It will take a while for everything to
come up as machines will have to download quite a few dependencies if
they're fresh.

.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
.. _playbook: http://docs.ansible.com/playbooks.html

