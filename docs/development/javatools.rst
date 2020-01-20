======================
Java Development Tools
======================

When developing with Java, you will want to use some tooling for deeper
analysis of failures, hot-redeploys of the application, etc.

Please step through the different tools below to learn how you can use them
when using a (local) Kubernetes deployment as a part of your development
workflow.

These functionality is only enabled in the development flavors of :doc:`/images/dataverse-k8s`.
You should not (and cannot) enable this in production.

.. seealso:: If you need to swap out your production pod, take a look at `telepresence <https://www.telepresence.io/>`_.

Metrics and Performance with VisualVM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Debugging with JDWP
^^^^^^^^^^^^^^^^^^^



Hot-Reploy of evolving parts with JRebel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On startup, when the environment variable ``ENABLE_JREBEL=1``, the application
server is configured to enable JRebel support on deployment.

You might set this variable in any way you like. On Kubernetes, the easiest way
is likely to be via the Dataverse ``ConfigMap`` (see also :doc:`/day1/config`):

.. code-block:: yaml

  # [...]
  data:
    ENABLE_JREBEL: "1"

Once your application server is up, JRebel communicates with the IDE extensions
via the very same port that you use to access Dataverse in the browser. Please
follow their instructions to configure your IDE plugin.

Below is an example using IntelliJ IDEA and its JRebel Plugin, syncing via
a ``kubectl port-forward`` from localhost into the cluster:

.. thumbnail:: img/jrebel-idea.png
  :title: JRebel in Dataverse Pod enabled in IntelliJ IDEA.

.. danger::

  You will need to raise the RAM limit of the pod when enabling this.
  Dev default 1 GiB RAM is not sufficient, 1.5 GiB (= 750 MiB heap) is bare
  minimum. You might need to add more RAM to your Kubernetes cluster, depending
  on your setup.

.. important::

  Please be aware that you will need a JRebel license to use this timesaving
  feature. Good products have a reasonable price. You have been warned.
  https://www.jrebel.com/products/jrebel

.. seealso::

  In the future, when Dataverse runs on Java JDK 11, one might take a look at
  http://hotswapagent.org. There are only outdated DCEVM patches for JDK 8,
  so this is currently not an alternative.
