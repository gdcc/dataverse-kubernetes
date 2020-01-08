.. tip::

  This document is primarily targeted at people developing the Dataverse
  application on a Kubernetes platform, run CI jobs or similar.

=================
Development usage
=================

Images on Docker Hub are meant for production usage or quick demos.
When developing Dataverse, testing a new feature not yet shipped in a release or
running integration tests you have a need to deploy all moving parts into
a (more or less) ephemeral environment.

More development topics:

.. toctree::
    :maxdepth: 2

    ./mail



Prepare toolchain
-----------------

For efficient workflows, tools make life easier. Please install:

1. `skaffold <https://skaffold.dev/docs/getting-started/#installing-skaffold>`_
2. `kustomize <https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md>`_
   (necessary as long as `this issue <https://github.com/GoogleContainerTools/skaffold/issues/1781>`_  hasn't been resolved)

When you opt for using a local cluster, add:

1. `Docker <https://docs.docker.com/install>`_
2. `kind <https://kind.sigs.k8s.io/docs/user/quick-start>`_ (currently the only supported option)

The tools mentioned in :doc:`/get-started/index` are obligatory.

You might consider using a tooling management tool (ha!) like `ASDF <https://asdf-vm.com>`_
for installation and keeping up-to-date.



Workflow
--------

While you can build and deploy everything manually, it will be easier to
let Skaffold take care of everything.

Running ``skaffold run`` or ``skaffold dev`` will build, tag and deploy for you.
For a deeper insight, read docs at https://skaffold.dev/docs.

As you will need to access services, be sure to add ``--port-forward``.
See also `port forward docs <https://skaffold.dev/docs/how-tos/portforward>`_.

**Before running Skaffold for the first time** be sure to have a cluster at hands.
You can check via ``kubectl``. Currently only using a local cluster with ``kind``
is supported by this project, see next section. *PRs welcome.*



A word on waiting
^^^^^^^^^^^^^^^^^

Be aware that initial builds and deployments take lots of time due to cold caches.
Recurring builds and deployments will be much faster, although you will still
suffer from Glassfish WAR deployment times.

.. caution::

  Deployment times of Dataverse are still a nightmare as of writing (Jan. 2020).
  For any change to the codebase, you most likely will have to wait about five
  to ten minutes to redeploy from compilation to reload of webpage.

  This is due to a really big WAR file (which needs to be loaded into the cluster)
  and being stuck on old technology in combination with a tremendous monolith.

  **YOU HAVE BEEN WARNED.**

Typically, when there is no change to ``pom.xml`` and build caches are warmed up,

- building will take about 1 minute,
- loading images into cluster about 45 secs,
- deploying to Kubernetes about 30 secs
- and Glassfish startup + WAR deployment about 3 minutes.

:subscript:`How about some coffee?`

Local cluster
-------------

The easiest way to work with a local cluster is using `kind <https://kind.sigs.k8s.io/docs/user/quick-start>`_,
which is an abbreviation for **K**\ ubernetes **IN D**\ ocker.

Skaffold supports this out of the box. Using ``kind``, your context will be set
to sth. like *"@kind"*, which triggers loading images into a local ``kind`` cluster
instead of pushing to a remote registry.

After installing Docker and ``kind``, you simply need to run:

.. code-block:: shell

  kind create cluster

or - if your prefer a specific K8s version, e.g. `1.14.6`:

.. code-block:: shell

  kind create cluster --image kindest/node:v1.14.6

.. note::

  Please note that ``kind`` might have some troubles with changing host networks and
  switching to a new DNS resolver. You might need to rebuild the cluster, which is
  no big deal (very fast).

If you want to use ``k3s``, ``minikube``, ``microk8s`` or similar, please consult the
Skaffold docs, search via Google, etc. Again: *PRs welcome.*

Remote cluster
--------------

Currently only using a :ref:`development/index:Local cluster` with ``kind`` is supported by this project.
*PRs and ideas welcome.*

.. hint::

  We'll most likely need `Kaniko <https://github.com/GoogleContainerTools/kaniko>`_
  or similar for that in your cluster, as Docker Hub must not be cluttered.



Future ideas
------------

- Test using `telepresence <https://www.telepresence.io>`_ - it might lower dev cycle time
- Try `JRebel <https://www.jrebel.com/products/jrebel>`_ to avoid full redeployments, see :issue:`101`
