.. versionadded:: 0.2

`haproxy https://github.com/CiscoCloud/haproxy-consul`_ connects to
:doc:`consul`, and proxies all registered services.

Variables
---------

.. data:: haproxy_image

   default: ``asteris/registrator``
          
.. data:: haproxy_image_tag

   default: ``latest``


.. data:: haproxy_domain 
  
   default: ``example.com``
 
   The domain that haproxy will use to match url requests. For example
   if this is set to example.com, apps will be mapped to app.example.com.

   For this to work, you need to have a wildcard dns entry for ``*.example.com``

.. _haproxy-example-playbook:


Example Playbook
----------------

.. code-block:: yaml+jinja

    ---
    - hosts: load_balancers
      roles:
        - haproxy
