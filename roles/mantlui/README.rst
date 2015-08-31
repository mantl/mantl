mantlui
=====

.. versionadded:: 0.4

Mantlui consolidates the web UIs of various components in Mantl, including Mesos, Marathon, Chronos, and Consul.

  - [x] Mesos UI
  - [x] Fix mesos leader redirection (don't have to go to the ui on the leader now)
  - [x] Stream mesos log
  - [x] View mesos task sandbox (without opening 5051 and tweaking hosts files)
  - [x] Stream mesos task stderr/stdout (and other artifacts)
  - [x] View/download mesos task artifacts
  - [x] Marathon UI
  - [x] Chronos UI
  - [x] Consul UI
  - [x] Consul Api
  - [x] Basic index page
  - [ ] Improve design
  - [ ] Favicon
  - [ ] Official nginx-mantlui repo
  - [ ] Official nginx-mantlui docker image
  - [ ] Package mesos webui changes (instead of overwriting files with Ansible)
  - [ ] Multi-DC aware?
  - [ ] Configurable Consul Access-Control-Allow-Origin
  - [ ] Remove nginx-mesos-leader
  - [ ] Remove nginx-marathon
  - [ ] Remove nginx-chronos
  - [ ] Remove nginx-consul? (this might be a more significant change since other components -- including nginx-consul -- use the proxy)
  - [ ] Update all documentation and update URLs

In the future, the static home page could become an application with a dashboard, health status, links to optional components and other mesos framework UIs, etc.

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
