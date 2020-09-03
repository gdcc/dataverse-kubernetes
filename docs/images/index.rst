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
    solr-k8s

Container Startup
-----------------

Solr Search index
^^^^^^^^^^^^^^^^^

Described in detail at :doc:`/day2/job-index`.

Dataverse Application Server
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the Kubernetes pod containing the application server container starts,
one of the following happens, dependent on the type of image you are using.

The following happens when using the :doc:`dataverse-k8s` or a derived image.

.. uml::

  @startuml
  !includeurl "https://raw.githubusercontent.com/michiel/plantuml-kubernetes-sprites/master/resource/k8s-sprites-unlabeled-25pct.iuml"

  participant "<color:#royalblue><$pod></color>\nContainer" as K
  participant Tini
  note right Tini: "Tiny init"\ngithub.com/krallin/tini
  participant "Entrypoint" as E
  participant "Init script" as I
  participant "Appserver" as A

  create Tini
  K -> Tini: Start

  create E
  Tini -> E: Start
  create I
  E -> I: Start

  create A
  I -> A: Start
  activate A
  I -> A: Configure password aliases
  I -> A: Configure keys for S3
  I -> A: Configure resources
  I -> A: Configure Dataverse\nJVM options
  I -> A: Stop
  destroy A
  I -> I: Symlink WAR & more

  create A
  E -> A: Start in foreground
  activate A
  E --> Tini: exec(): replace with Appserver
  destroy E
  Tini -> A: Keep running until container stops
  A -> A: Autodeploy WAR
  @enduml
