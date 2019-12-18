========
Building
========

Currently, **only Docker is supported** for image building. Find details how to
install Docker see `upstream documentation <https://docs.docker.com/install>`_.

You might try to build with `Podman <https://podman.io>`_ or
`Buildah <https://buildah.io>`_. This has the advantage of no need to run
a Docker daemon, which might be easier when using your custom CI.
As of podman v1.6.2 images seem to build successfully.



Build release images
--------------------

Simple with Docker (or Podman) after cloning the project and accessing the source folder:

.. code-block:: shell

  docker build -t iqss/dataverse-k8s:4.16 -f docker/dataverse-k8s/glassfish/Dockerfile .
  docker build -t iqss/solr-k8s:4.16 docker/solr-k8s


*Please remember to change the tag above as appropriate. You should be*
*using tagged images as best practice, not empty or* ``latest``.


.. _prepare-dev:

Prepare development images
--------------------------

.. note::

  You don't need to worry about anything related to Dataverse like compilation.
  Image building will take care of it. So if you don't have Maven installed,
  don't use an IDE or just want to try out sth.: you are all set. Go ahead.

For building images from any branch or commit of Dataverse, you need to have
it in your (Docker) build context. Easily achieved by running the following
after cloning the project:

.. code-block:: shell

  git submodule sync --recursive
  git submodule update --init --recursive

This will checkout the upstream Dataverse ``develop`` branch into ``./dataverse``.
If you want a feature branch, add your fork or whatever necessary: just follow normal
``git submodule`` routines. (For example, goto ``./dataverse`` and ``git checkout``
your branch.)
For more on submodules, have a look
`here <https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407>`_,
`here <https://chrisjean.com/git-submodules-adding-using-removing-and-updating>`_,
`here <https://gist.github.com/gitaarik/8735255>`_ or
`here <https://lmgtfy.com/?q=git+submodule>`_.

You can even point your IDE to this new subfolder and it will work like a champ.


Build development images
------------------------

In most cases, you will want to let tools automatically build new images for you.
See below for your options.

.. note:: Currently there is no Solr development image. This is likely to change.

Manual build
^^^^^^^^^^^^
Simply use Docker or other build tool again (almost like above, but different path):

.. code-block:: shell

  docker build -t iqss/dataverse-k8s:test -f docker/dataverse-k8s/glassfish-dev/Dockerfile .

Automatic build with Skaffold
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Please see :doc:`/get-started/development` for this. It will make your life
easier, promise.
