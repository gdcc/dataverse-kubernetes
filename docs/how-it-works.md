# Inner workings of Dataverse Kubernetes application

Please familiarize yourself with the architecture of Dataverse if not already
done: http://guides.dataverse.org/en/latest/installation

It helps a lot knowing how things are connected in Dataverse to understand
what happens when using Kubernetes in addition.

In this chapter you may find detailed documentation about how things are
connected together in this Kubernetes application in a visual way.
In doubt consult the scripts and descriptors in this repository.

## Initial Deployment Procedure

The below image shows all necessary steps by you (the user) or your deployment
framework (like Terraform, Ansible and similar) for a new deployment of Dataverse.
It also explains what happens in the background on an overview level.
For more details please look at the demos or code.

*The below image is loaded from Garvizo. It might be not shown completely. Try reloading and empty cache.*

![Alt text](https://g.gravizo.com/source/mark_deployment?https%3A%2F%2Fraw.githubusercontent.com%2FIQSS%2FDataverse-kubernetes%2Fmaster%2Fdocs%2Fhow-it-works.md)
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
mark_deployment
</details>

## Dataverse Container Startup

When the Kubernetes pod containing the application server container starts (using the
image [iqss/dataverse-k8s](https://hub.docker.com/r/iqss/dataverse-k8s) by default, but you might derive or use your own), the following
happens:

![Alt text](https://g.gravizo.com/source/mark_container_startup?https%3A%2F%2Fraw.githubusercontent.com%2FIQSS%2FDataverse-kubernetes%2Fmaster%2Fdocs%2Fhow-it-works.md)
<details>
<summary></summary>
mark_container_startup
  @startuml
  participant Tini
  note left Tini: "Tiny init"\ngithub.com/krallin/tini
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
mark_container_startup
</details>

##
