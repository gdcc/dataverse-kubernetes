=================
Search Index Jobs
=================

When you handle updates and upgrades of the Dataverse application or :doc:`rollout
your custom metadata schema <job-metadata>` (blocks), you will need to take care
of your search index, based on Solr.

.. _reindex:

Inplace Re-Indexing
-------------------

There are two main reasons when you might need to rebuild your search index:

1. Sometimes upgrading to a new Dataverse version, the Solr configuration
   has been changed by upstream. In these cases, release notes will advise you to
   :guide_dv:`do an "inplace reindex" <admin/solr-search-index.html#reindex-in-place>`.
2. You :doc:`changed your metadata schema <job-metadata>`, renamed fields, changed type etc. A data
   migration is not possible for our index, instead we need to rebuild it.

For your convenience, a batch job has been added, containing all actions mentioned
in the docs. Simply deploy it during off-hours (or fork and create a ``CronJob``):

.. code-block:: shell

  kubectl create -f k8s/dataverse/jobs/inplace-reindex.yaml

.. hint::

  Beware, this type of re-index does not guarantee for a clean index. See
  :guide_dv:`upstream index guide <admin/solr-search-index.html>`.

Update Solr schema with custom metadata fields
----------------------------------------------

The :doc:`Solr container </images/solr-k8s>` comes with a default index configuration,
supporting the :guide_dv:`upstream metadata schemas <user/appendix.html#metadata-references>`.
This configuration resides in ``${$COLLECTION_DIR}/conf`` (see also
:ref:`important directories of the image <images/solr-k8s:Important directories>`).

Dataverse provides an :guide_dv:`API endpoint to retrieve a Solr schema configuration
<admin/metadatacustomization.html#updating-the-solr-schema>` fitting the metadata
schemas present in your Dataverse installation. We use a forked version of the
`upstream script <https://github.com/IQSS/dataverse/blob/master/conf/solr/7.3.1/updateSchemaMDB.sh>`_
at ``$SCRIPT_DIR/schema/update.sh`` to generate an updated configuration and reload Solr.

.. important::

  Most likely you will need to do :ref:`reindex` after deploying new schemas.
  Many, if not all schema changes will also require a rebuild of your index.

... gracefully when starting Solr
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As the Solr index configuration is not persisted, but loaded from Dataverse,
we need to ask Dataverse for it when Solr starts. This is done via an init
container.

This is done gracefully with a fallback to the default upstream metadata.
Unless you change those, worst case is loosing searchability of custom
metadata when configuration is not available during startup.

.. uml::

  @startuml
  !includeurl "https://raw.githubusercontent.com/michiel/plantuml-kubernetes-sprites/master/resource/k8s-sprites-unlabeled-25pct.iuml"
  hide footbox

  participant "<color:#royalblue><$job></color>\nMetadata Update Job" as MDJ
  box "Solr Pod"
    participant "<color:#royalblue><$pod></color>\nSchema Init" as SI
    participant "<color:#royalblue><$pod></color>\nSchema Sidecar" as SS
    participant "<color:#royalblue><$pod></color>\nSolr" as Solr
  end box
  participant "<color:#royalblue><$pod></color>\nDataverse" as DV

  == Startup ==

  activate SI
  SI -> SI : Call //update.sh//
  activate SI
  SI -> DV ++ : Request metadata fields
  DV --> SI -- : Send fields
  SI -> SI : Write Solr configuration to ///schema//
  SI --> SI : Trigger //RELOAD// (will fail on purpose)
  deactivate SI

  SI --> SI : Fail gracefully
  destroy SI
  create SS
  SI --> SS : //init done//
  create Solr
  SI --> Solr : //init done//

  @enduml

.. hint::

  To understand the above, please keep in mind that init, sidecar and
  main Solr container share ``/schema`` via ``emptyDir`` volume.

... when updating metadata schemas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A sidecar container of Solr ``Pod``, executed by a webhook. This webhook is
fired by the :ref:`metadata update <meta-update>` ``Job`` for you, once
metadata blocks have been uploaded.

.. uml::

  @startuml
  !includeurl "https://raw.githubusercontent.com/michiel/plantuml-kubernetes-sprites/master/resource/k8s-sprites-unlabeled-25pct.iuml"
  hide footbox

  participant "<color:#royalblue><$job></color>\nMetadata Update Job" as MDJ
  box "Solr Pod"
    participant "<color:#royalblue><$pod></color>\nSchema Sidecar" as SS
    participant "<color:#royalblue><$pod></color>\nSolr" as Solr
  end box
  participant "<color:#royalblue><$pod></color>\nDataverse" as DV

  MDJ -> SS : Fire webhook
  activate SS

  SS -> SS : Check request,\nTranslate parameters,\nCall //update.sh//
  activate SS

  SS -> DV ++ : Request metadata fields
  DV --> SS -- : Send fields

  SS -> SS : Write Solr configuration to ///schema//
  SS -> Solr : Trigger //RELOAD//
  activate Solr

  Solr -> Solr : Restart core,\nLoad configuration\nfrom ///schema// now
  Solr --> SS
  deactivate Solr

  SS --> SS
  deactivate SS

  SS --> MDJ : Send status code and script output (to be logged)
  deactivate SS
  @enduml

.. hint::

  To understand the above, please keep in mind that init, sidecar and
  main Solr container share ``/schema`` via ``emptyDir`` volume.

.. seealso::

  Webhooks implemented using https://github.com/adnanh/webhook and extendable
  if necessary.
