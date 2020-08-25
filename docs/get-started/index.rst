===============
Getting started
===============

.. toctree::
    :maxdepth: 2
    :hidden:

    demo/k3s
    demo/minikube

`The dataverse project <http://dataverse.org>`_ describes itself as:

  | Dataverse is an open source web application to share, preserve, cite, explore,
  | and analyze research data. It facilitates making data available to others, and
  | allows you to replicate others' work more easily. Researchers, journals, data
  | authors, publishers, data distributors, and affiliated institutions all receive
  | academic credit and web visibility.

------------------------------------
Introduction: what's this all about?
------------------------------------
This project aims at offering a new way to deploy, run and maintain a Dataverse
installation for any purpose on any kind of Kubernetes-based cloud infrastructure.

You can use this on your laptop, in your on-prem datacentre or public cloud.
With the power of `Kubernetes <http://kubernetes.io>`_, many scenarios are possible.

.. tip::

  | **tl;dr...**
  | Quick'n'dirty demo persona on naked cluster [1]_:

  .. code-block:: shell

    kubectl apply -k github.com/IQSS/dataverse-kubernetes/personas/demo

  Wait. Regularly check logs and pods. Login with ``dataverseAdmin:admin1``.

  .. [1] *Your mileage may vary due to storage classes. You really should look at the* :ref:`demos <demos>` *below.*






----------------------------------
Prerequisites: First things first.
----------------------------------

Before you start deploying, make sure to look at the following checklist:

| **1. Think first**

If you never touched a commandline, never thought about why using cloud
infrastructure might be a good idea: maybe you should stick with the old,
but paved and solid ways of installing complex applications like Dataverse.

Keen to learn new technology? Be part of the future? Want to streamline
CI/CD and your application? *Continue*.

| **2. Install tools**

You will at least need:

- `kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl>`_, at least version 1.14
- `git <https://git-scm.com/downloads>`_ (or another VCS)

Depending on your use-case and targeted environment that might be just it.
If something else is necessary, it'll be documented in its respective documentation part.

| **3. Grasp some knowledge**

If you never used Kubernetes, but want to deploy to production, you definitely
should be reading some docs first. Some starting points:

- https://kubernetes.io/docs/tutorials/kubernetes-basics/
- https://ramitsurana.github.io/awesome-kubernetes
- https://kubernetes-on-aws.readthedocs.io/en/latest/admin-guide/kubernetes-in-production.html

| **4. Grab a cluster**

You'll need a running and fully configured Kubernetes cluster.

- Local options:

  - `k3s <https://k3s.io>`_
  - `minikube <https://kubernetes.io/docs/setup/learning-environment/minikube/>`_
  - `microk8s <https://microk8s.io>`_
  - `kind <https://kind.sigs.k8s.io/>`_

- Deploy your own (production) cluster. Many tools to choose from. Examples:

  - `kops <https://kubernetes.io/docs/setup/production-environment/tools/kops/>`_
  - `kubespray <https://kubernetes.io/docs/setup/production-environment/tools/kubespray/>`_

- Use a hosted solution. Some example services at

  - Google: `GKE <https://cloud.google.com/kubernetes-engine>`_
  - Microsoft: `Azure AKS <https://azure.microsoft.com/services/kubernetes-service>`_
  - Amazon: `AWS EKS <https://aws.amazon.com/de/eks>`_
  - RedHat: `OpenShift <https://www.openshift.com>`_

| **5. Choose persistent identifiers**

When you want to register datasets and/or files in your deployment to
DataCite, EZID or similar, you will need active accounts. Be sure to have
access credentials around. As an alternative, you might want to use the FAKE provider.

.. seealso::

  For more information on Dataverses supported providers:

  - `Installation Guide: Persistent Identifiers and Publishing Datasets <http://guides.dataverse.org/en/latest/installation/config.html#persistent-identifiers-and-publishing-datasets>`_
  - `Installation Guide: Configuration Option :DoiProvider <http://guides.dataverse.org/en/latest/installation/config.html#doiprovider>`_





---------------------------------------------
Use Cases: What installation persona are you?
---------------------------------------------

.. _demos:

1. Demo time!
-------------
Demos provide showcases what Dataverse can do for you. Currently pre-packaged:

- Local

  - Using ``minikube``, see :doc:`demo/minikube`
  - Using ``k3s``, see :doc:`demo/k3s`

- Cloud-based

  - Using ``kops`` on Amazon EC2 VMs, see :doc:`demo/aws-kops`

2. Developing is my thing
-------------------------

There is an entire section in this guide dealing with how to use this project
for developing Dataverse, run development snapshots for tech demos, etc.

Please go to :doc:`development docs here </development/index>`.

3. Gimme the *production* stuff
----------------------------------

.. todo::
  This needs yet to be refactored.

You should make yourself familiar with a series of documentation articles, linked below:

* [Container images](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/images.md)
* [Persistance storage](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/storage.md)
* [Detailed insight into inner workings](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/how-it-works.md)
* [Using Kubernetes descriptors from this project](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/reuse.md)
* [Configuration of Dataverse](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/config.md)
* [Secrets usage](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/secrets.md)
* [(Custom) Metadata Blocks](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/metadata.md)
* [Maintenance Jobs and Little Helpers](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/little-helpers.md)

Please be aware that this project currently only offers images and support
for basic usage. Integrations are not yet part of this, but may be added as needed.
See also relevant docs within Dataverse guides and upstream projects.

4. Integrate yourself!
----------------------
One of the true superpowers of Dataverse is its ability to integrate with external
tools. Previewers, data analysis, data capturing and many more await you.

.. hint::

  Currently, none of these are supported or maintained by this project, although
  this is a mid-term goal. If you feel a need, raise an issue. You are most
  welcome to contribute.

Apart from external tools, Dataverse can be integrated with :doc:`external
authentication </day3/auth>` systems and :doc:`object storage </day3/objectstore>`,
which is supported by this project.
