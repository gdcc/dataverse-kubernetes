Deploying, Running and Using Dataverse on Kubernetes
====================================================

.. image:: https://raw.githubusercontent.com/IQSS/dataverse-kubernetes/master/docs/img/title-composition.png

|Dataverse badge|
|Validation badge|
|DockerHub dataverse-k8s badge|
|DockerHub solr-k8s badge|
|License badge|
|Docs badge|
|IRC badge|

This community-supported project aims to provide simple to re-use Kubernetes
objects on how to run Dataverse on a Kubernetes cluster.

It aims at day-1 deployments and day-2 operations.

* Documentation: https://dataverse-k8s.rtfd.io
* Support: https://github.com/IQSS/dataverse-kubernetes/issues
* Roadmap: https://dataverse-k8s.rtfd.io/en/latest/roadmap.html

If you would like to contribute, you are most welcome. Head over to the
`contribution guide <https://dataverse-k8s.rtfd.io/en/latest/contribute.html>`_
for details.

This project follows the same branching strategy as the upstream Dataverse
project, using a ``release`` branch for stable releases plus a ``develop``
branch. In this branch unexpected or breaking changes may happen.



.. |Dataverse badge| image:: https://img.shields.io/badge/Dataverse-v4.19-important.svg
   :target: https://dataverse.org
.. |Validation badge| image:: https://jenkins.dataverse.org/job/dataverse-k8s/job/Kubeval%20Linting/job/master/badge/icon?subject=kubeval&status=valid&color=purple
   :target: https://jenkins.dataverse.org/blue/organizations/jenkins/dataverse-k8s%2FKubeval%20Linting/activity?branch=master
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
