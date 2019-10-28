======================
Using *k3s.io* persona
======================

The *k3s.io persona* is about deploying Dataverse to *k3s.io* for **local
development or demo purposes**.


.. seealso::
  `k3s.io <https://k3s.io>`_ is a very small and simplicity first Kubernetes
  distribution, targeted at use cases like (tiny) microservices, continious integration,
  internet of things etc. Compared to *minikube*, *k3s* is even smaller and more lightweight.
  You can run *k3s* on hardware, a virtual machine or in a Docker container.

Start with setup of *k3s.io*
----------------------------

First, setup a single node K3s cluster. Pick your poison. Once you
have your cluster up and running, continue.

As K3s removed all "in-tree" storage classes, you will need to provide
one on your own. For simple purposes like demos or development, local storage
is sufficient.

.. note::
  The *k3s.io* persona will add a `local provisioner <https://github.com/rancher/local-path-provisioner>`_ by default,
  so the default storage class will "just work".

For getting started quickly, you can use *k3s.io* on *Docker* easily with *k3d*. You'll need:

- `Docker <https://docs.docker.com/install>`_
- `k3d <https://github.com/rancher/k3d/releases>`_

Now create a small test cluster for this demo:

.. code-block:: shell

  k3d create --publish 8080:80 --wait 0
  export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"

.. hint::
  Remember you need to expose the ``Ingress`` port, thus the ``--publish 8080:80``. Ingress will be reachable via http://localhost:8080 later.



Let's get ready to Dataverse...
-------------------------------

.. important::

  Please be aware that the *k3s.io* persona is using `Kustomize <https://kustomize.io>`_
  to re-use the provided descriptors, but suited for usage with K3s.
  Please ensure having *kubectl* v1.14 or later installed as described in :doc:`/get-started/index`.

Now start to deploy Dataverse plus any necessary services and bootstrap via Kustomize:

.. code-block:: shell

  kubectl apply -k ./personas/k3s

When bootstrapping job finished (see ``kubectl get job,pod`` and logs), you can
"just access" Dataverse. *k3s.io* persona adds an ``Ingress`` route from
your host to the service.

Point your favorite browser to http://localhost:8080 and enjoy your freshly backed Dataverse demo.

.. hint::

  Default login for this demo is ``dataverseAdmin:admin1``. See :doc:`/day1/secrets`.


A word on deployment times
^^^^^^^^^^^^^^^^^^^^^^^^^^
On a 2016 laptop with

- 16 GB RAM,
- SATA SSD,
- Intel Core i5-6300U and
- a fairly fast internet connection for image pulling

it takes about **3 to 4 minutes** from zero to hero, not including installation time
for Docker, k3d/k3s or kubectl.
