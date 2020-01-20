.. tip::

  This section is primarily targeted at people developing the Dataverse
  application on a Kubernetes platform, run CI jobs or similar.

=================
Development usage
=================

Images on Docker Hub are meant for production usage or quick demos.
When developing Dataverse, testing a new feature not yet shipped in a release or
running integration tests you have a need to deploy all moving parts into
a (more or less) ephemeral environment.

Please prepare your environment first:

.. toctree::
    :maxdepth: 2

    ./prepare
    ./mail



Workflow
--------

While you can build images manually (see below) and deploy manually, it will be
much easier to let Skaffold take care of it.

Running ``skaffold run`` or ``skaffold dev`` from the root of the project will
build, tag and deploy for you.

For a deeper insight, read docs at https://skaffold.dev/docs.

Initial deployment
^^^^^^^^^^^^^^^^^^

**STOP.** You did :doc:`preparation for this <prepare>`, did ya? Go ahead.

Now lets no more time, and create our initial deployment, already using your
checked out branch of Dataverse:

.. code-block:: shell

  skaffold run -p init

:subscript:`(Between us: this will simply deploy the demo persona and the bootstrap job for you.)`

While you are waiting for the deployment to finish
(see :ref:`development/index:A word on waiting` for more), think about how you
will access your cluster. Your options:

1. When using ``skaffold dev`` (see below!), you can add ``--port-forward``.
   See also `port forward docs <https://skaffold.dev/docs/how-tos/portforward>`_.
   This is currently not possible with ``run`` mode.
2. When using Minikube, see :ref:`get-started/demo/minikube:Make Dataverse reachable via browser`
3. When using KinD, easiest way forward is ``kubectl port-forward``. ``Ingress``
   is also possible, see `upstream doc <https://kind.sigs.k8s.io/docs/user/ingress>`_.

Example workflow for local development
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. uml::

  @startuml
  (*) -right-> "Prepare toolchain,\ncluster & source files"
  -right-> "Edit source files" as E
  -right-> "skaffold run"
  --> "Port forward"
  -left-> "Access Dataverse in browser"
  -up-> E
  @enduml


.. important::

  You might choose not to use ``skaffold dev``, as build and deploy times are long.
  Using it means every saved file will trigger the deploy chain, which is pretty
  expensive.

.. warning::

  Currently only using a local cluster with ``kind`` is supported by this
  project when using Skaffold. See :ref:`preparing cluster <development/prepare:Spin up Cluster>`.
  *PRs welcome.*




Build development images manually
---------------------------------

In most cases, you will want to let tools automatically build new images for you.
See below for your options.

Simply use Docker or other build tool again (almost like above, but different path):

.. code-block:: shell

  docker build -t iqss/dataverse-k8s:test -f docker/dataverse-k8s/glassfish-dev/Dockerfile .
  docker build -t iqss/solr-k8s:test docker/solr-k8s

.. note:: Currently there is no Solr development image. This is likely to change.



A word on waiting
-----------------

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


Future ideas
------------

- Test using `telepresence <https://www.telepresence.io>`_ - it might lower dev cycle time
- Try `JRebel <https://www.jrebel.com/products/jrebel>`_ to avoid full redeployments, see :issue:`101`
