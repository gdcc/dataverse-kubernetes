# How it works...

In this file you may find detailed documentation about how things are connected together in this Kubernetes application.

## Initial Deployment Procedure

![Alt text](https://g.gravizo.com/source/mark_deployment?https%3A%2F%2Fraw.githubusercontent.com%2FIQSS%2FDataverse-kubernetes%2F44-add-docs%2Fdocs%2Fhow-it-works.md)
<details>
<summary></summary>
mark_deployment
  @startuml
  actor User
  participant "Secrets" as S
  participant "ConfigMap" as CM
  participant "PostgreSQL" as P
  participant "Dataverse" as D
  participant "Bootstrap Job" as BJ
  participant "Configure Job" as CJ

  participant "Solr"

  create S
  User -> S: Deploy Secrets
  create CM
  User -> CM: Deploy ConfigMap
  note over P: Optional!\nFire at will.
  create P
  User -> P: Deploy PostgreSQL
  CM -> P: Pass username +\ndatabase name
  S -> P: Pass password
  P -> P: Init database

  create Solr
  User -> Solr: Deploy Solr from iqss/solr-k8s

  create D
  User -> D: Deploy Dataverse from iqss/dataverse-k8s
  D -> D: Deploy app
  note over D: see also in detail at\n"Container Startup"
  D -> P: Persistance Framework:\nCreate tables
  P --> D: Done

  create BJ
  User -> BJ: Deploy Bootstrapping Job
  S -> BJ: Pass db password\n+API key
  CM -> BJ: Pass settings
  BJ <<-->> P: wait for
  BJ <<-->> Solr: wait for
  BJ <<-->> D: wait for
  ...After Dataverse has been deployed successfully......
  BJ -> P: Additional SQL init
  BJ -> D: Bootstrapping w/ setup-all.sh\n(Metadata, user, root dataverse, ...)
  activate D
  BJ -> D: Configure Solr location\n+ admin contact
  BJ -> D: Block API with unblock-key
  D -> P: Store settings
  return

  create CJ
  User -> CJ: Deploy Configure Job
  S -> CJ: Pass API key
  CM -> CJ: Pass settings
  CJ -> D: Configure DB settings via API
  activate D
  D -> P: Store settings
  return

  User -> D: Start accessing Dataverse
  @enduml
mark_deployment
</details>

## Dataverse Container Startup

![Alt text](https://g.gravizo.com/source/mark_container_startup?https%3A%2F%2Fraw.githubusercontent.com%2FIQSS%2FDataverse-kubernetes%2F44-add-docs%2Fdocs%2Fhow-it-works.md)
<details>
<summary></summary>
mark_container_startupp
  @startuml
  participant Tini
  participant "Entrypoint" as E
  participant "Init script" as I
  participant "Appserver" as A

  create E
  Tini -> E: Start
  create I
  E -> I: Start

  create A
  I -> A: Start
  activate A
  I -> A: Configure password aliases
  I -> A: Configure resources
  I -> A: Configure JVM options
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
mark_container_startup
</details>
