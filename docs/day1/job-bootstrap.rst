=============
Bootstrap Job
=============

After deploying every components of Dataverse on Kubernetes for the first time
(see :doc:`./init-deploy`), you will need to bootstrap your installation.
That will create a superadmin user, root dataverse and block important API endpoints.

It will also set the option ``:SolrHostColonPort``, configuring where Dataverse
can find the Solr Search index. It will default to ``solr:8983``, but can be
overridden by setting a hostname or IP in ``SOLR_K8S_HOST`` via ``ConfigMap``
(see :doc:`config`).

When the very basic configuration has been done, the configuration given in the
``ConfigMap`` will be applied, like you would
:ref:`run a configure Kubernetes job <day1/config:Details of the configuration job>`.

.. uml::

  @startuml
  !includeurl "https://raw.githubusercontent.com/michiel/plantuml-kubernetes-sprites/master/resource/k8s-sprites-unlabeled-25pct.iuml"

  actor User
  participant "<color:#royalblue><$secret></color>\nSecrets" as S
  participant "<color:#royalblue><$cm></color>\nConfigMap" as CM
  participant "<color:#royalblue><$pod></color>\nPostgreSQL" as P
  participant "<color:#royalblue><$pod></color>\nDataverse" as D
  participant "<color:#royalblue><$job></color>\nBootstrap Job" as BJ
  participant "<color:#royalblue><$pod></color>\nSolr" as Solr

  create BJ
  User -> BJ: Deploy Bootstrapping Job
  S -> BJ: Pass db password\n+API key
  CM -> BJ: Pass settings
  BJ <<-->> P: wait for
  BJ <<-->> Solr: wait for
  BJ <<-->> D: wait for

  ... After Dataverse, Solr and PostgreSQL have been reached successfully... ...

  BJ -> P: Additional SQL init
  BJ -> D: Bootstrapping w/ setup-all.sh\n(Metadata, user, root dataverse, ...)
  activate D
  BJ -> D: Configure Solr location\n+ admin contact
  BJ -> D: Block API with unblock-key
  D -> P: Store settings
  BJ -> D: Configure Dataverse DB-based\nsettings via API (like a Config Job)
  D -> P: Store settings
  return
  destroy BJ

  @enduml
