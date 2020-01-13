=================
Search Index Jobs
=================

When you handle updates and upgrades of the Dataverse application or :doc:`rollout
your custom metadata schema <job-metadata>` (blocks), you will need to take care
of your search index, based on Solr.

"Inplace Re-Index" Job
----------------------

Sometimes when you upgrade to a new Dataverse version, the Solr configuration
has been changed by upstream. In these cases, release notes will advise you to
:guide_dv:`do an "inplace reindex" <admin/solr-search-index.html#reindex-in-place>`.

For your convenience, a batch job has been added, containing all actions mentioned
in the docs. Simply deploy it during off-hours (or fork and create a ``CronJob``):

.. code-block:: shell

  kubectl create -f k8s/dataverse/jobs/inplace-reindex.yaml

Update Solr Search Index
------------------------

.. todo::

  Needs fixing for release 4.17 containing necessary (upstream) scripts.
