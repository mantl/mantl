Haproxy
=======

.. versionadded:: 0.2

`Haproxy <haproxy https://github.com/CiscoCloud/haproxy-consul>`_ connects to
:doc:`consul`, and proxies all registered services. At the current time all
containers are mapped to port 80. Future versions will allow each container to
control the haproxy port and url mapping.

Variables
---------

Depends on ``haproxy_domain``, as we use host_acl on the hostname in the
request.

.. data:: haproxy_image

   default: ``asteris/haproxy-consul``
          
.. data:: haproxy_image_tag

   default: ``latest``

.. data:: haproxy_domain 
  
   default: ``example.com``
 
   The domain that haproxy will use to match url requests. For example if this
   is set to example.com, apps ``myapp`` and ``hello-world`` will be mapped to
   ``myapp.example.com``, ``hello-world.example.com``.

   For this to work, you need to have a wildcard dns entry for
   ``*.example.com``, so when your browser goes to ``http://myapp.example.com``,
   your DNS settings forward that traffic to one of the nodes running haproxy.
