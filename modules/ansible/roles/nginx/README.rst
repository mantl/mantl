Nginx
=====

`Nginx <http://nginx.org/>`_ is a web and proxy server.
Mantl uses it in front of the :doc:`mesos`,
:doc:`marathon`, and :doc:`consul` web UIs to provide basic authentication and
SSL. Those proxies are set up in the individual roles linked above, and the base
``nginx`` role is just used to move the relevant certificates into place.
