Certificates
============

.. versionadded:: 1.2

This role generates TLS certificates for each node. In the future, we'd like
to integrate this role more closely with Vault, and allow automated periodic
recreation of certificates.

Caution: This role will distribute your CA private key to all nodes. This isn't
a security risk if you're using self-signed certificates. If you use a signed
CA, you'll want to delete this key from your nodes. You should always use an
intermediate CA with Mantl.

Currently, you cannot upload your own pre-generated host certificates. Mantl
requires that various special hostnames and IP addresses are valid for each cert,
and these values depend on your configuration.

See ``roles/certificates/defaults/main.yml`` for more information on the
variables you can use to customize this role.
