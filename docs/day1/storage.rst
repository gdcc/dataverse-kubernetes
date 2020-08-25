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

      When using remote storage (like S3), you may use an ``emptyDir`` volume
      for temporary upload storage.

      Keep in mind that as of Dataverse v4.20, you may enable multiple storage
      locations, mix-n-matching local and remote storages.
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

  * - **/dumps**
    - Heap dumps area
    - In case of :ref:`running out of heap space <day1/resources:Shortage of Heap Space>`,
      heap dumps will be saved here for further shipping, analysis etc.
      By default this is backed by an ``emptyDir`` temporary storage volume.
      Should be monitored in a sidecar container.

Temporary Data Storage
^^^^^^^^^^^^^^^^^^^^^^
Depending on the ``dataverse_files_directory`` :doc:`setting <config>` data
uploaded by users will be stored  in a ``temp`` sub-directory of the given
path for processing (ingest) and moving to final location. With default
``/data``, this will result in temporary storage at ``/data/temp``.

Remember to have temporary storage available at ``/dumps``. Heap dumps
might grow as large as your configured container memory limits and storing
them on the overlay filesytem of the container is a bad idea.

"Local" Data Storage
^^^^^^^^^^^^^^^^^^^^
*Local storage* is any kind of volume mounted into the application container. It
*will look like a local filesystem to the application.

It might be a ``hostPath`` flavored volume, a Docker volume, a NFS share or even
a clustered file system. Plenty of options are available for Kubernetes.
For any mounts, you should think about using a subdirectory of ``/data``.

Remember that you will have to ensure proper permissions on the mounted volume
(the appserver uses ``uid=1000, gid=1000``). One option to solve this is by
adding an init container to your deployment object:

.. code-block:: yaml

  initContainers:
    - name: volume-mount-hack
      image: giantswarm/tiny-tools
      command: ["sh"]
      args:
        - -c
        - chown -c 1000:1000 /data/mystorage
      volumeMounts:
        - name: mystorage
          mountPath: /data/mystorage


Remote Data Storage
^^^^^^^^^^^^^^^^^^^
*Remote storage* is any kind of storage not mounted as a local filesystem,
reachable over a network and having storage driver support inside Dataverse.
Examples are any S3-based or Swift object stores.

They can be activated via :doc:`configuration <config>` in your ``ConfigMap``.
Please see upstream documentation about
:guide_dv:`file storage <installation/config.html#file-storage-using-a-local-filesystem-and-or-swift-and-or-s3-object-stores>`
for extensive docs on the available options. :ref:`full-example` provides
a handy S3 example using Minio.

Further explenaition and an example can be found in the integration docs about
:doc:`/day3/objectstore`.

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
