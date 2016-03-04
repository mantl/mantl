Custom Playbook
===============

Your customized ``mantl.yml`` `playbook`_ should be used to deploy
Mantl to your servers.

Below is an annotated playbook explaining the values:

.. literalinclude:: ../../sample.yml
   :language: yaml+jinja

Run this playbook with ``ansible-playbook -i plugins/inventory/terraform.py -e
@security.yml /path/to/your/playbook.yml``. It will take a while for everything
to come up as fresh machines will have to download quite a few dependencies.

.. _playbook: http://docs.ansible.com/playbooks.html

