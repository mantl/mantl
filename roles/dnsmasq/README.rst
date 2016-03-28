dnsmasq
=======

The project uses `dnsmasq <http://www.thekelleys.org.uk/dnsmasq/doc.html>`_ to
configure each host to use :doc:`consul` for DNS.

Changes
-------

.. versionadded: 1.0.4

Starting with version 1.0.4, dnsmasq no longer uses Google's DNS (``8.8.8.8``
and ``8.8.4.4``), preferring the cloud provider's DNS. If you want to use the
old behavior, add your preferred nameservers to ``/etc/resolv.conf.masq``, where
DNSMasq will look to load resolvers after a name is not found in Consul.

Variables
---------

The dnsmasq role uses ``consul_dns_domain``, ``consul_servers_group``, and
``consul_dc_group`` defined in :doc:`consul`.

.. data:: mantl_dns_version

   The version of ``mantl-dns`` to install.

   Default: ``1.0.0``
