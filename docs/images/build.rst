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

  docker build -t iqss/dataverse-k8s:4.19 -f docker/dataverse-k8s/glassfish/Dockerfile .
  docker build -t iqss/solr-k8s:4.19 docker/solr-k8s


*Please remember to change the tag above as appropriate. You should be*
*using tagged images as best practice, not empty or* ``latest``.

.. seealso::

  Building development flavored images is described at :doc:`/development/index`.

Build with ``podman``
---------------------

When building images with ``podman``, you need to be aware that DNS and hostname
is handled differently than with Docker.

If you see an error like ``There is a process already using the admin port 4848``
failing the build, you might fear of a DNS problem.

Please try to use ``podman build --add-host=$(hostname):127.0.0.1 ...`` as your
build command, otherwise the appserver will not start because it cannot reach
your host IP from within the container.

See also http://www.adam-bien.com/roller/abien/entry/when_there_is_a_process
