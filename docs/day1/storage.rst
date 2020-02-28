==================
Storage and Backup
==================

This project aims to make things as stateless as possible. Obviously, somewhere
databases, search indices, research data, etc have to reside and are statefull.

The following sections describe usefull mount locations for Dataverse services.
You still need to think about the PostgreSQL database storage and backup on your own.

Application server
------------------

Dataverse is a Java EE application, deployed to an application server.
It is all packaged in :doc:`the dataverse-k8s image </images/dataverse-k8s>` for
you. Following the documented :ref:`important directories <images/dataverse-k8s:Important Directories>`
there, some hints how to cope with that on Kubernetes:

.. list-table:: Storage for dataverse-k8s
  :widths: 10 17 73
  :header-rows: 1

  * - Directory
    - Description
    - Usage, ideas, hints

  * - **/data**
    - Research data area
    - Use a *ReadWriteMany* type volume when using a multi-instance deployment.

      When using object storage like S3 or Swift, you might configure it as ``emptyDir`` volume for temporary upload only.
  * - **/docroot**
    - Web application area
    - Users upload data into this area. Dataverse application writes data here.
      You will need a *ReadWriteMany* type of volume or sync the content otherwise.
      As with metadata (see below), you might consider using init containers or
      sidecars to pre-populate this area with your files.

  * - **/metadata**
    - Custom metadata schema area
    - To :doc:`roll your own custom metadata blocks </day2/job-metadata>`,
      you need to populate this directory. A sidecar pattern is likely to be a
      good fit for this, retrieving data from remote (like a Git repository).


Index server
------------

Dataverse uses `Solr <https://lucene.apache.org/solr/>`_ as an index and search
engine for all datasets of research data. It is a statefull application by nature.
We provide a :doc:`derived image </images/solr-k8s>` using upstream releases, adding our specialized
configuration and tools to it.

.. list-table:: Storage for dataverse-k8s
  :widths: auto
  :header-rows: 1

  * - Directory
    - Description
    - Usage, ideas, hints
  * - **/opt/solr/server/solr/collection1/data**
    - Index data
    - Currently, Solr is used in standalone mode only. A multi-instance variant
      is not yet supported, but might be added. (This would be using SolrCloud mode then.)
      A *ReadWriteOnce* volume type should be sufficient for now.
