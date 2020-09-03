=================
Behind the Scenes
=================

The below UML sequence diagram shows all necessary steps by "you"
(the user activity on the left) or (preferably) your deployment framework
(like Kustomize.io, Helm or similar) on your behalf for a new deployment of
Dataverse. It explains what happens in the background on an overview level.

When you are done with the initial deployment, you have to :doc:`bootstrap </day1/job-bootstrap>`
(and :doc:`configure </day1/config>`, which is done during bootstrapping, too).

.. uml::

  @startuml
  !includeurl "https://raw.githubusercontent.com/michiel/plantuml-kubernetes-sprites/master/resource/k8s-sprites-unlabeled-25pct.iuml"

  actor User
  participant "<color:#royalblue><$secret></color>\nSecrets" as S
  participant "<color:#royalblue><$cm></color>\nConfigMap" as CM
  participant "<color:#royalblue><$pod></color>\nPostgreSQL" as P
  participant "<color:#royalblue><$pod></color>\nDataverse" as D
  participant "<color:#royalblue><$pod></color>\nSolr" as Solr

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
  Solr -> Solr: Init container:\nFix volume permissions\nDeploy schemas

  create D
  User -> D: Deploy Dataverse from iqss/dataverse-k8s
  D -> D: Init container:\nFix volume permissions
  D <<-->> P: wait for
  D <<-->> Solr: wait for
  D -> D: Deploy app
  note right: see also in detail at\n"Container Startup"
  D -> P: Persistance Framework:\nCreate tables
  P --> D: Done

  @enduml
