============
Architecture
============

Please familiarize yourself with the `architecture of Dataverse <http://guides.dataverse.org/en/latest/installation>`_
if not already done: it helps a lot knowing how things are connected in Dataverse
to also understand using it as a Kubernetes application.

In this chapter you may find detailed documentation about how things are
connected together in this Kubernetes application in a visual way (UML sequence diagrams).
In doubt consult the scripts and descriptors in this repository.

Initial Deployment Procedure
----------------------------

The below image shows all necessary steps by "you" (the user activity on the left)
or (preferably) your deployment framework (like Kustomize.io, Helm or similar)
on your behalf for a new deployment of Dataverse. It also explains what happens
in the background on an overview level. For more details please look at the demos or code.

.. uml::
  :width: 100%

  @startuml
  !includeurl "https://raw.githubusercontent.com/michiel/plantuml-kubernetes-sprites/master/resource/k8s-sprites-unlabeled-25pct.iuml"

  actor User
  participant "<color:#royalblue><$secret></color>\nSecrets" as S
  participant "<color:#royalblue><$cm></color>\nConfigMap" as CM
  participant "<color:#royalblue><$pod></color>\nPostgreSQL" as P
  participant "<color:#royalblue><$pod></color>\nDataverse" as D
  participant "<color:#royalblue><$job></color>\nBootstrap Job" as BJ
  participant "<color:#royalblue><$job></color>\nConfigure Job" as CJ
  participant "<color:#royalblue><$pod></color>\nSolr" as Solr

  == Deploy application ==

  create S
  User -> S: Deploy Secrets
  create CM
  User -> CM: Deploy ConfigMap
  note over P: Optional!
  create P
  User -> P: Deploy PostgreSQL
  CM -> P: Pass username +\ndatabase name
  S -> P: Pass password
  P -> P: Init database

  create Solr
  User -> Solr: Deploy Solr from iqss/solr-k8s
  Solr -> Solr: Init container:\nFix volume permissions

  create D
  User -> D: Deploy Dataverse from iqss/dataverse-k8s
  D -> D: Init container:\nFix volume permissions
  D -> D: Deploy app
  note right: see also in detail at\n"Container Startup"
  D -> P: Persistance Framework:\nCreate tables
  P --> D: Done

  == Bootstrapping ==

  create BJ
  User -> BJ: Deploy Bootstrapping Job
  S -> BJ: Pass db password\n+API key
  CM -> BJ: Pass settings
  BJ <<-->> P: wait for
  BJ <<-->> Solr: wait for
  BJ <<-->> D: wait for
  ...After Dataverse, Solr and PostgreSQL have been deployed successfully......
  BJ -> P: Additional SQL init
  BJ -> D: Bootstrapping w/ setup-all.sh\n(Metadata, user, root dataverse, ...)
  activate D
  BJ -> D: Configure Solr location\n+ admin contact
  BJ -> D: Block API with unblock-key
  D -> P: Store settings
  return
  destroy BJ

  == Further Configuration ==
  create CJ
  User -> CJ: Deploy Configure Job
  S -> CJ: Pass API key
  CM -> CJ: Pass settings
  CJ <<-->> D: wait for
  ...After Dataverse ready......
  CJ -> D: Configure Dataverse DB-based\nsettings via API
  activate D
  D -> P: Store settings
  return
  destroy CJ

  == Start using ==
  User -> D: Start accessing Dataverse
  @enduml





Dataverse Container Startup
---------------------------

When the Kubernetes pod containing the application server container starts,
one of the following happens, dependent on the type of image you are using.

Glassfish release flavor
^^^^^^^^^^^^^^^^^^^^^^^^
This happens when using the image `iqss/dataverse-k8s <https://hub.docker.com/r/iqss/dataverse-k8s>`_ or a derived image.

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
