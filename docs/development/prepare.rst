===================
Prepare environment
===================

Install Toolchain
-----------------

For efficient workflows, tools make life easier. Please install:

1. `skaffold`_, v1.2.0
2. `kustomize`_, v2.0.3 (same as in ``kubectl``, necessary as long as
   `this issue <https://github.com/GoogleContainerTools/skaffold/issues/1781>`_
   hasn't been resolved)

When you opt for using a local cluster (see below), add:

1. `minikube`_ or
2. `kind`_, v0.7.0 plus `Docker <https://docs.docker.com/install>`_

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





Spin up cluster
---------------

Wether you need a test, ephemeral, staging or whatever cluster, using the tools
outlined here is just *one* example how to do it. Take this as a proven working
path, but feel free to roll your own and give feedback.

Local cluster
^^^^^^^^^^^^^
When running on your laptop or workstation, you have two options.
Either use ``minikube`` or ``kind``.

Minikube is easier to get started with, but uses more resources.
KinD is not so easy, but very low on resource usage. Up to you.

If you want to use ``k3s``, ``microk8s`` or similar, please consult the
Skaffold docs, search via Google, etc. Again: *PRs welcome.*

Minikube
''''''''

Please follow :ref:`get-started/demo/minikube:Start with setup of *minikube* VM`
to create your cluster. No need to deploy yet, we are just preparing for now.

**K**\ ubernetes **IN** **D**\ ocker ("KinD")
'''''''''''''''''''''''''''''''''''''''''''''

Skaffold supports this out of the box. Using ``kind``, your context will be set
to sth. like *"kind-kind"*, which triggers loading images into a local ``kind`` cluster
instead of pushing to a remote registry.

After installing Docker and ``kind``, you simply need to run (context will be
set for you):

.. code-block:: shell

  kind create cluster

.. toggle-header::
  :header: If you prefer a specific K8s version, e.g. `1.14.6` *expand/hide*

  .. code-block:: shell

    kind create cluster --image kindest/node:v1.14.6

.. note::

  Please note that ``kind`` might have some troubles with changing host networks and
  switching to a new DNS resolver. You might need to rebuild the cluster, which is
  no big deal (very fast).


Remote cluster
^^^^^^^^^^^^^^

Currently only using a :ref:`development/prepare:Local cluster` with ``kind`` is supported by this project.
*PRs and ideas welcome.*

.. hint::

  We'll most likely need `Kaniko <https://github.com/GoogleContainerTools/kaniko>`_
  or similar for that in your cluster, as Docker Hub must not be cluttered.





Clone source files
------------------

For building images from any branch or commit of Dataverse, you need to have
it in your (Docker) build context. Easily achieved by running the following
after cloning the project (``master`` branch):

.. code-block:: shell

  git submodule sync --recursive
  git submodule update --init --recursive

This will checkout the upstream Dataverse project into ``./dataverse``, pulling
the ``develop`` branch and tags. Please read the below carefully.

.. tip::

  1. For more on how to use Git Submodules, have a look
     `here <https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407>`_,
     `or here <https://chrisjean.com/git-submodules-adding-using-removing-and-updating>`_,
     `maybe here <https://gist.github.com/gitaarik/8735255>`_ or
     `or last resort <https://lmgtfy.com/?q=git+submodule>`_.
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



Checkout target branch
----------------------

When a release in this project is tagged, the submodule is updated to point to
the latest commit available upstream. For any real world scenarios, you will
need to checkout something different.

If you want a feature branch, add your fork or whatever necessary: just follow normal
``git submodule`` routines.

Example: Switch to latest ``develop``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  cd ./dataverse
  git checkout develop
  git pull origin develop:develop

Example: Switch to feature branch in (your) fork
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  cd ./dataverse
  git remote add poikilotherm https://github.com/poikilotherm/dataverse.git
  git fetch poikilotherm
  git pull poikilotherm poikilotherm/5974-oidc-impl:testbranch
  git checkout testbranch

.. _skaffold: https://skaffold.dev/docs/getting-started/#installing-skaffold
.. _kustomize: https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md
.. _kind: https://kind.sigs.k8s.io/docs/user/quick-start
.. _minikube: https://kubernetes.io/docs/setup/learning-environment/minikube
