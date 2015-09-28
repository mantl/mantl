mantlui
=====

.. versionadded:: 0.4

Mantlui consolidates the web UIs of various components in Mantl, including Mesos, Marathon, Chronos, and Consul at a single url on port 80 (http) or 443 (https).

- [x] Mesos UI (/mesos)
    - [x] Fixes mesos leader redirection (don't have to go to the ui on the leader now)
    - [x] Stream mesos logs
    - [x] View mesos task sandbox
    - [x] Stream mesos task stderr/stdout (and other artifacts)
    - [x] View/download mesos task artifacts
- [x] Marathon UI (/marathon)
- [x] Chronos UI (/chronos)
- [x] Consul UI (/consul)

Variables
---------

You can use these variables to customize your Mantlui installation.

.. data:: mantlui_nginx_image

   nginx-mantlui docker container image name

   default: ``ryane/nginx-mantl``

.. data:: mantlui_nginx_image_tag

   nginx-mantlui docker container image tag

   default: ``0.1``

.. data:: do_mantlui_ssl

   Use https to secure the mantlui.

   default: ``false``

.. data:: do_mantlui_auth

   Use basic authentication to secure the mantlui.

   default: ``false``
