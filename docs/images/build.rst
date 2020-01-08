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

.. seealso::

  Building development flavored images is described at :doc:`/development/index`.
