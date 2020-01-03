=======================
Credentials and Secrets
=======================

The Dataverse Java EE application needs to access remote resources like
a PostgreSQL database or a persistent identifier service like DataCite.
For this you'll need credentials, which are meant to be kept secret.

Credentials in Dataverse application container
----------------------------------------------

Credentials used in Dataverse may be found in the upstream `Installation
Guide <http://guides.dataverse.org/en/latest/installation>`_, mostly in the
`config section <http://guides.dataverse.org/en/latest/installation/config.html>`_.

Besides the credentials, you might need to think of certificates, too, depending
on your actual setup. Your mileage may vary.

Concept
^^^^^^^

The basic idea behind credentials used in the Dataverse application container
based on the :doc:`dataverse-k8s image </images/dataverse-k8s>` is using
environment variables to promote them. These mechanisms are described in
:doc:`config`, too.

Non-Secret Materials
^^^^^^^^^^^^^^^^^^^^

You can provide credentials directly as environment variables from your
``Deployment``, ``PodPreset``, ``ConfigMap``, ``Secret`` et al. When not using
Kubernetes, environment variables is still a widely used concept.

Silent Secrets
^^^^^^^^^^^^^^

Please keep in mind that passing in *secret* information like a password, key or
similar should be done otherwise. For these, you can mount files at certain places
(see :doc:`image documentation </images/dataverse-k8s>`), which will be read and
piped into an environment variable, crafted into a JVM password alias,
configuration files, etc.

Example: PostgreSQL connection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example is about the PostgreSQL credentials and can be adapted to different
use cases. It uses the Kubernetes concept of ``Secrets`` (see below).
More examples can be found at ``/personas/demo/secrets.yaml``.

.. code-block:: bash

    kubectl create secret generic dataverse-postgresql \
                --from-literal=username='dataverse' \
                --from-literal=password='changeme' \
                --from-literal=database='mydataverse'

Executing the above will create a ``Secret`` in your Kubernetes cluster.
It could be used in the ``Deployment`` like this (excerpt) to configure
username, password and database name for the Dataverse PostgreSQL service:

.. code-block:: yaml
    :emphasize-lines: 7,10-11,16-17,20,26-27

    kind: Deployment
    # ...
        spec:
          containers:
            - name: dataverse
              image: iqss/dataverse-k8s
              env:
                - name: POSTGRES_USER
                  valueFrom:
                    secretKeyRef:
                      name: dataverse-postgresql
                      key: username
                      optional: true
                - name: POSTGRES_DATABASE
                  valueFrom:
                    secretKeyRef:
                      name: dataverse-postgresql
                      key: database
                      optional: true
              volumeMounts:
                - name: db-secret
                  mountPath: "/opt/dataverse/secrets/db"
                  readOnly: true
          volumes:
            - name: db-secret
              secret:
                secretName: dataverse-postgresql

Example: Admin account password
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The password for the superadmin account ``dataverseAdmin`` defaults to **admin1**
when you install (precise: bootstrap) Dataverse on Kubernetes.

Create a ``Secret`` first (or use some other way to get the password into the file).
(For a complete ``Secret`` example, have a look at ``/personas/demo/secrets.yaml``)

.. code-block:: yaml

    kind: Secret
    # ...
    metadata:
      name: dataverse-admin
      # ...
    stringData:
      password: admin1

If you did not use the default ``dataverse-admin`` name for the secret, you will
have to adapt the boostrap ``Job`` spec with your secret name.

During bootstrap, the mounted secret at `${SECRETS_DIR}/admin/password` provisions
your password while creating the account. A less secure way is to provide it as environment
variable `ADMIN_PASSWORD`.

.. hint::
  Using a password not matching the enabled password policies will force you
  to provide a new password on first login. See the
  `Dataverse guides <http://guides.dataverse.org/en/latest/installation/config.html#enforce-strong-passwords-for-user-accounts>`_
  for more details.

.. danger::

  You really should change it to something more secure when not used for ephemeral purposes.

.. note::

   1. This default password is the same as `IQSS/dataverse-ansible <https://github.com/IQSS/dataverse-ansible>`_ uses.
   2. This is a bootstrap-time-only option. You cannot reset your password this way.





How to use secret informations within K8s
-----------------------------------------

Keeping things secret in a Kubernetes cluster needs attention at a few places:

- Secure storage at rest
- Secure distribution in/across cluster
- Secure usage in containers

For production environments, you really should be looking closely at all of this.
Every admin admires sleeping at nighttimes and not putting out fires.

Secure usage
^^^^^^^^^^^^

Read more about `distributing credentials in Kubernetes <https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/>`_
in the upstream documentation and below.

.. todo::
  Write more things, link stuff.

Please use [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and *mount them as volumes*.
See also [here](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume).


Secure storage and distribution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::
  -> Secure storage
  -> Encrypt etcd
  -> Sealed Secretes
  -> Systems like Vault etc
  -> env vs file
