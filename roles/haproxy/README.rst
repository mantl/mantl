.. versionadded:: 0.2

`Haproxy <haproxy https://github.com/CiscoCloud/haproxy-consul>`_ connects to
:doc:`consul`, and proxies all registered services. At the current time all containers are mapped to port 80. Future versions will allow each container to control the haproxy port and url mapping.  

Variables
---------
Depends on ``haproxy_domain``, as we use host_acl on the hostname in the request. 

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
