===================
Prepare environment
===================

Toolchain
---------

For efficient workflows, tools make life easier. Please install:

1. `skaffold <https://skaffold.dev/docs/getting-started/#installing-skaffold>`_
2. `kustomize <https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md>`_
   (necessary as long as `this issue <https://github.com/GoogleContainerTools/skaffold/issues/1781>`_  hasn't been resolved)

When you opt for using a local cluster (see below), add:

1. `Docker <https://docs.docker.com/install>`_
2. `kind <https://kind.sigs.k8s.io/docs/user/quick-start>`_ (currently the only supported option)

.. important::

  The tools mentioned in :doc:`/get-started/index` are obligatory.

.. tip::

  You might consider using a tooling management tool (ha!) like `ASDF <https://asdf-vm.com>`_
  for installation and keeping up-to-date.

.. note::

  You don't need to worry about anything related to Dataverse Java compilation
  and packaging. Image building will take care of it. So if you don't have
  Maven installed, don't use an IDE (like in CI) or just want to try out sth.:
  you are all set. Go ahead.





Cluster
-------

Wether you need a test, ephemeral, staging or whatever cluster, using the tools
above is just one example how to do it. Take this as a proven working path, but
feel free to roll your own and give feedback.

Local cluster
^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^

Currently only using a :ref:`development/index:Local cluster` with ``kind`` is supported by this project.
*PRs and ideas welcome.*

.. hint::

  We'll most likely need `Kaniko <https://github.com/GoogleContainerTools/kaniko>`_
  or similar for that in your cluster, as Docker Hub must not be cluttered.





Source files
------------

For building images from any branch or commit of Dataverse, you need to have
it in your (Docker) build context. Easily achieved by running the following
after cloning the project (``master`` branch):

.. code-block:: shell

  git submodule sync --recursive
  git submodule update --init --recursive

This will checkout the upstream Dataverse project into ``./dataverse``, pulling
the ``develop`` branch and tags. Please read the below carefully.

Moving on to your target
^^^^^^^^^^^^^^^^^^^^^

When a release in this project is tagged, the submodule is updated to point to
the latest commit available upstream. For any real world scenarios, you will
need to checkout something different.

If you want a feature branch, add your fork or whatever necessary: just follow normal
``git submodule`` routines.

Example to switch to latest ``develop``:

.. code-block:: shell

  cd ./dataverse
  git checkout develop

Example to switch to a feature branch in a GitHub fork:

.. code-block:: shell

  cd ./dataverse
  git remote add poikilotherm https://github.com/poikilotherm/dataverse.git
  git fetch poikilotherm
  git pull poikilotherm poikilotherm/5974-oidc-impl:testbranch
  git checkout testbranch

.. tip::

  1. For more on how to use Git Submodules, have a look
     `here <https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407>`_,
     `here <https://chrisjean.com/git-submodules-adding-using-removing-and-updating>`_,
     `here <https://gist.github.com/gitaarik/8735255>`_ or
     `here <https://lmgtfy.com/?q=git+submodule>`_.
  2. You can even point your IDE to this new subfolder and it will work like a champ.

.. note::

  .. toggle-header::
    :header: You think this is weird and/or cumbersome? *Expand/hide*

    As long as K8s usage is not a first class citizen for IQSS, this project should
    not (or cannot) be included in Dataverse upstream.

    .. code-block:: diff

      + We don't have to deal with upstream merge process for PRs and can move independent and quicker.
      + We can use tools like Skaffold, Kustomization, etc only usable when living at the topmost level.
      - We have to deal with `git submodules` and somewhat bloated image builds.
      - We cannot use fancy Maven tools like JIB and others.
