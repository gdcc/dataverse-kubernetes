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
                  mountPath: "/secrets/db"
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


Example: Builtin Users API Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default, your installation is secured to not allow other builtin users next
to ``dataverseAdmin``. If you need or want to change this, you can provision a
secret value to the ``BuiltinUsers.KEY`` setting when bootstrapping.

As this is an extension to the API, you need to extend your API secret as
shown below.

.. code-block:: yaml

   kind: Secret
   # ...
   metadata:
     name: dataverse-api
     # ...
   stringData:
     key: your-super-secret-unblock-key
     userskey: your-even-more-secure-BuiltinUsers.KEY-value

During bootstrap, the mounted secret at `${SECRETS_DIR}/api/userskey` is read
and provisioned.

.. note::

  This is a bootstrap-time-only option. This cannot be set by configuration job
  by design. You still could use a manual ``curl`` call.



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

The most important thing to understand is how to deal with secret information
when configuring Dataverse and using services. Obviously you will need to inject
the secret data into running containers. There are multiple ways to do so, but
to be safe there are "best practices":

1. Use `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_
   to store secret information. No excuses.
2. Prefer `mounting secrets as (memory-backed) text files <https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume>`_
   in containers rather than pushing into environment variables (easier to sneak
   on those than files).

Read more about `securely injecting credentials in containers <https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/>`_
in the upstream documentation and below.

.. note::

  For bigger clusters, applications, levels of security, etc. this might
  be insufficient. You should read articles on third-party tools, like
  `this <https://blog.aquasec.com/managing-kubernetes-secrets>`_ and others.

Secure storage and distribution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Right under the container level there are some other attack vectors, where a
maleficent guy could sneak on your secrets:

1. Cluster communication between your services, K8s services and K8s nodes
2. Stored secrets, used harddisks

There are checklists for being production ready with a K8s cluster. Use 'em.
`Example <https://www.replex.io/blog/kubernetes-in-production-best-practices-for-governance-cost-management-and-security-and-access-control>`_.

Some basics (taken from `here <https://kubernetes.io/blog/2018/07/18/11-ways-not-to-get-hacked>`_):

- Secure communication by using TLS wherever possible.
- Especially secure communication with ``etcd``, which holds your secret data decrypted.
- Let ``etcd`` `encrypt its data when at rest <https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/>`_.

You should also think about your deployment workflow for secrets. It might be a
good idea to use tools like `Vault <https://vault.io>`_. If you like `GitOps <https://www.weave.works/technologies/gitops>`_,
take a look at the `concept of sealed secrets <https://learnk8s.io/kubernetes-secrets-in-git>`_
(multiple implementation around).
