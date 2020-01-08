===================
Metadata Blocks Job
===================

This is about handling upstream changes to "system" metadata blocks and
how to handle custom metadata block support.
See also `upstream documentation about customizing metadata <http://guides.dataverse.org/en/latest/admin/metadatacustomization.html>`_.

Add custom metadata blocks
--------------------------

Deploying metadata is reusing the :doc:`/images/dataverse-k8s` by default.
You need to drop metadata TSV files to the ``/metadata`` directory of the jobs
container (see also :ref:`important directories of dataverse-k8s <images/dataverse-k8s:Important Directories>`)

This can happen via

- custom/derived images
- volume mounts
- ``ConfigMap`` file mounts
- sidecar container(s), downloading/cloning/checking out/...

.. hint::

  ``ConfigMaps`` seem to be the easiest option, but in case you use large or large
  amounts of custom metadata blocks, you might consider using a different.



Update Dataverse metadata blocks
--------------------------------

Simply deploy a metadata update job:

.. code-block:: shell

  kubectl create -f k8s/dataverse/jobs/metadata-update.yaml

.. hint::

  Remember: you will need to get your custom metadata inside that job somehow, see above.

Force re-export of citation metadata after update
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Especially when the core ``citation.tsv`` metadata schema changed, you will need
to re-export all citation metadata. A simple job does the trick:

.. code-block:: shell

  kubectl create -f k8s/dataverse/jobs/metadata-reexport.yaml

Having a large set of published dataverses and datasets, you might want to run
this during off-hours.

See also `upstream docs <http://guides.dataverse.org/en/latest/admin/metadataexport.html>`_.



Update Solr Search Index
------------------------

.. todo::

  Needs fixing for release 4.17 containing necessary (upstream) scripts.
