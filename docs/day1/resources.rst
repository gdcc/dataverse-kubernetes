===================
Resources and Usage
===================

As with every application, you will need to plan and maintain the usage of
resources like CPU time, memory and storage for Dataverse and its components.

Details about storage can be found at :doc:`storage`.

Memory
------

Dataverse and Solr both being Java technology based components need to be
tweaked for memory usage. Obviously the values below count per instance.

.. list-table:: Memory planning
  :widths: 30 20 20 20
  :header-rows: 1

  * - Component
    - Min RAM
    - Min Heap
    - Recommendend min. RAM
      for production use
  * - Application server w/ Dataverse
    - 1 GiB
    - 512 MiB
    - 4 GiB
  * - Solr Search Index
    - 1 GiB
    - 512 MiB
    - 4 GiB

.. hint::
  The JVM will by default use 25% of RAM for it's heap. No need to add an
  operating system reserve when running in containers on K8s.

Configuring pods memory
^^^^^^^^^^^^^^^^^^^^^^^

Since Java 8u192 the Hotspot VM is natively supporting container resource limits.
To configure these limits, simply configure it in the ``Deployment`` object:

.. code-block:: yaml

  spec:
    template:
      spec:
        containers:
          - name: dataverse
            resources:
              requests:
                memory: "2Gi"
              limits:
                memory: "4Gi"

.. important::

  You can easily apply your settings by using a patch and kustomize. Please find
  an example in the demo persona directory ``/persona/demo``.

.. seealso::

  For development or demo use, you'll be good in most cases with much less.
  When running with only 1 GiB of RAM, you need to tweak the JVM to use at least
  512 MiB of heap space. Using less heap space will not even deploy successfully.

  .. toggle-header::
    :header: Development values are hidden on purpose to avoid confusion. *Expand/hide*

    .. code-block:: yaml

      spec:
        template:
          spec:
            containers:
              - name: dataverse
                resources:
                  requests:
                    memory: "1Gi"
                  limits:
                    memory: "1Gi"
                env:
                  - name: MAX_RAM_PERCENTAGE
                    value: "50.00"

  How much RAM is used at max for Java Heap can be easily adjusted by using the
  JVM option ``-XX:MaxRAMPercentage=xx.xx``. For your convenience this has been
  simplified by supporting an environment variable ``${MAX_RAM_PERCENTAGE}``,
  see hidden example above. *Please keep in mind: must be a floating point value!*
