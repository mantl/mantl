the security-setup script
=========================

The ``security-setup`` script is located in the root of the project. It will set
up authentication and authorization for you, as described in the :doc:`component
documentation <../components/index>`. When components are updated, you can run
it again, as many times as you want. It will only set the variables it needs to.

After you've set up security with the script, you can include it in your
playbook runs by specifying the ``-e`` or ``--extra-vars`` option, like so::

    ansible-playbook --extra-vars=@security.yml your_playbook.yml

Certificates
------------

If not present, ``security-setup`` will create a root CA to generate
certificates from. If you want to use your own CA, add the key in
``ssl/private/cakey.pem`` and the cert in ``ssl/cacert.pem``.

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

Run ``security-setup --help`` to see a list of options with their default
values. Options like ``--mesos`` take a boolean argument. You can use the
following values in these options:

======= ==============
Value   Interpreted as
======= ==============
`t`     True
`T`     True
`1`     True
`True`  True
`true`  True
`f`     False
`F`     False
`0`     False
`False` False
`false` False
======= ==============
