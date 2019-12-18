================
Container Images
================

This project provides ``Dockerfile`` s and scripts included in container
images to be used for Dataverse deployment and maintenance.

1. You can use images from Docker Hub. Those are built and tested by CI on every
   push to ``master`` and tags.
2. Derive from these and push your customized image to a place you like.
3. Build the genuine images yourself and push to a registry of your choice.

.. note::

  Currently, images on Docker Hub contain released upstream versions of Dataverse only.
  See image documentation for details.

.. toctree::
    :maxdepth: 2

    build
    dataverse-k8s
