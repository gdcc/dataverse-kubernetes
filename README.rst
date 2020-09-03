Deploying, Running and Using Dataverse on Kubernetes
====================================================

.. image:: docs/img/title-composition.png

|Dataverse badge|
|Validation badge|
|DockerHub dataverse-k8s badge|
|DockerHub solr-k8s badge|
|License badge|
|Docs badge|
|IRC badge|

This community-supported project aims at offering a new way to deploy, run and
maintain a Dataverse installation for any purpose on any kind of Kubernetes-based
cloud infrastructure.

You can use this on your laptop, in your on-prem datacentre or public cloud.
With the power of `Kubernetes <http://kubernetes.io>`_, many scenarios are possible.

* Documentation: https://dataverse-k8s.rtfd.io
* Support and new ideas: https://github.com/IQSS/dataverse-kubernetes/issues

If you would like to contribute, you are most welcome.

This project follows the same branching strategy as the upstream Dataverse
project, using a ``release`` branch for stable releases plus a ``develop``
branch. In this branch unexpected or breaking changes may happen.



.. |Dataverse badge| image:: https://img.shields.io/badge/Dataverse-v4.20-important.svg
   :target: https://dataverse.org
.. |Validation badge| image:: https://jenkins.dataverse.org/job/dataverse-k8s/job/Kubeval%20Linting/job/release/badge/icon?subject=kubeval&status=valid&color=purple
   :target: https://jenkins.dataverse.org/blue/organizations/jenkins/dataverse-k8s%2FKubeval%20Linting/activity?branch=release
.. |DockerHub dataverse-k8s badge| image:: https://img.shields.io/static/v1.svg?label=image&message=dataverse-k8s&logo=docker
   :target: https://hub.docker.com/r/iqss/dataverse-k8s
.. |DockerHub solr-k8s badge| image:: https://img.shields.io/static/v1.svg?label=image&message=solr-k8s&logo=docker
   :target: https://hub.docker.com/r/iqss/solr-k8s
.. |License badge| image:: https://img.shields.io/github/license/IQSS/dataverse-kubernetes
.. |Docs badge| image:: https://readthedocs.org/projects/dataverse-k8s/badge/?version=latest
   :target: https://dataverse-k8s.rtfd.io/en/latest
   :alt: Documentation Status
.. |IRC badge| image:: https://img.shields.io/badge/IRC%20chat-%23dataverse-blue
   :target: https://kiwiirc.com/client/irc.freenode.net/?nick=dataverse_k8s_?#dataverse
   :alt: Our IRC channel
