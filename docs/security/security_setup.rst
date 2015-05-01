the security-setup script
=====================

The ``security-setup`` script is located in the root of the project. It will set up
authentication and authorization for you, as described in the :doc:`component
documentation <../components/index>`. When components are updated, you can run it
again, as many times as you want. It will only set the variables it needs to.

After you've set up security with the script, you can include it in your
playbook runs by specifying the ``-e`` or ``--extra-vars`` option, like so::

    ansible-playbook site.yml --extra-vars=@security.yml

Certificates
------------

If not present, ``security-setup`` will create a root CA to generate certificates
from. If you want to use your own CA, add the key in ``ssl/private/cakey.pem``
and the cert in ``ssl/cacert.pem``.

If you have your own (self)signed certificates, you can put them in
``ssl/private/your.key.pem`` and ``ssl/certs/your.cert.pem``. Just override the
locations the script generates (for example the consul key and cert would be
``ssl/private/consul.key.pem`` and ``ssl/certs/consul.cert.pem``, respectively)
and they'll be used instead of the generated files, and not overridden.

In the event that you need to regenerate a certificate, rename or delete the
appropriate CSR and certificate from the ``certs`` folder and the private
component in ``private`` and re-run ``security-setup``.

Options
-------

.. program:: security-setup

.. option:: -h, --help

   Show the help message and exit

.. option:: --no-verify-certificates

   By default ``security-setup`` will verify certificates when it runs, to make
   sure they're still valid. However, do the way OpenSSL handles verification
   errors this check may be somewhat brittle. If this gives you trouble, disable
   it by specifying this flag.

.. option:: --change-admin-password

   ``security-setup`` will normally ask for an admin password only if it doesn't
   already have one. Setting this option will cause ``auth-setup`` to re-prompt
   for the admin password.

.. option:: --cert-country

   Country to be used for certificates

   default: ``US``

.. option:: --cert-state

   State/region to be used for certificates

   default: ``New York``

.. option:: --cert-locality

   Locality to be used for certificates

   default: ``Anytown``

.. option:: --cert-organization

   Organization to be used for certificates

   default: ``Example Company Inc``

.. option:: --cert-unit

   Operational unit to be used for certificates

   default: ``Operations``

.. option:: --cert-email

   Contact email to use for certificates

   default: ``operations@example.com``

.. option:: --consul-location

   Location Consul will be accessed at. This will be used as the common name in
   the Consul certificate.

   default: ``consul.example.com``

.. option:: --nginx-location

   Location nginx will be accessed at. This will be used as the common name in
   the nginx certificate.

   default: ``nginx.example.com``
