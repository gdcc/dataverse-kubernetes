# How it works...

In this file you may find detailed documentation about how things are connected together in this Kubernetes application.

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
