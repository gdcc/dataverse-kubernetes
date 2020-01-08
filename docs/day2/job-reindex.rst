======================
"Inplace Re-Index" Job
======================

Sometimes when you upgrade to a new Dataverse version, the Solr configuration
has been changed by upstream. In these cases, release notes will advise you to
`do an "inplace reindex" <http://guides.dataverse.org/en/latest/admin/solr-search-index.html#reindex-in-place>`_.

For your convienience, a batch job has been added, containing all actions mentioned
in the docs. Simply deploy it during off-hours (or fork and create a ``CronJob``):

.. code-block:: shell

  kubectl create -f k8s/dataverse/jobs/inplace-reindex.yaml
