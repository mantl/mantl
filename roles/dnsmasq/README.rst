dnsmasq
=======

The project uses `dnsmasq <http://www.thekelleys.org.uk/dnsmasq/doc.html>`_ to
configure each host to use :doc:`consul` for DNS.

Variables
---------

The dnsmasq role uses ``consul_dns_domain``, ``consul_servers_group``, and
``consul_dc_group`` defined in :doc:`consul`.
