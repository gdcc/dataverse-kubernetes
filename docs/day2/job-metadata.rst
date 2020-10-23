===================
Metadata Blocks Job
===================

This is about handling upstream changes to "system" metadata blocks and
how to handle custom metadata block support.

- :guide_dv:`Upstream documentation about customizing metadata <admin/metadatacustomization.html>`
- :guide_dv:`List of default, upstream supported metadata schemas <user/appendix.html#metadata-references>`

.. _meta-update:

Deploy and update Dataverse metadata blocks
-------------------------------------------

Many upstream releases contain changes to the upstream metadata schemas.
Simply deploy a "metadata update job".

Deploying your own custom schemas can be done in the same way. You will need to
get your custom metadata inside that job somehow, see below.

.. code-block:: shell

  kubectl create -f https://gitcdn.link/repo/IQSS/dataverse-kubernetes/release/k8s/dataverse/jobs/metadata-update.yaml

.. important::

  Please be sure to read :doc:`job-index` thoroughly, too. You might need to
  reindex, depending on changes.

.. uml::

  @startuml
  start
  :Find all TSV in /metadata (and /opt/dataverse);
  :Load all schemas via POST;
  :Trigger webhook to reconfigure Solr Index;
  stop
  @enduml

.. _meta-export:

Force re-export of citation metadata after update
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Especially when the core ``citation.tsv`` metadata schema changed, you will need
to re-export all citation metadata. A simple job does the trick:

.. code-block:: shell

  kubectl create -f https://gitcdn.link/repo/IQSS/dataverse-kubernetes/release/k8s/dataverse/jobs/metadata-reexport.yaml

Having a large set of published dataverses and datasets, you might want to run
this during off-hours.

See also :guide_dv:`upstream admin guide <admin/metadataexport.html>` about
metadata exports.

How to get custom metadata blocks inside the job
------------------------------------------------

Deploying metadata is reusing the :doc:`/images/dataverse-k8s` by default.
You need to drop metadata TSV files to the ``/metadata`` directory of the jobs
container (see also :ref:`important directories of dataverse-k8s <images/dataverse-k8s:Important Directories>`)

This can happen via

- custom/derived images
- volume mounts
- ``ConfigMap`` file mounts
- sidecar container(s), downloading/cloning/checking out/...

.. hint::

  1. ``ConfigMaps`` seem to be the easiest option, but in case you use large or large
     amounts of custom metadata blocks, you might choose differently.
  2. You could override upstream blocks this way. *You shouldn't do it.* Up to you.

Example with ``curl`` init container
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You could create a ``Job`` based on ``k8s/dataverse/jobs/metadata-update.yaml``,
which you extend like below.
(:download:`Download full example <examples/metadata-update-w-init.yaml>`)

.. literalinclude:: examples/metadata-update-w-init.yaml
   :language: yaml
   :lines: 19,20,26,30-32,33,44-54,55,59-60
   :name: metadata-update-w-init
