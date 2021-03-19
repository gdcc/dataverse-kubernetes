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
    - 1.5 GiB
    - 768 MiB
    - 4 GiB
  * - Solr Search Index
    - 820 MiB
    - 410 MiB
    - 4 GiB

.. hint::
  The JVM will by default use 70% of RAM for it's heap. No need to add an
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
  You need to ensure the JVM uses at least ~800 MiB for heap space.
  Using less heap space will not even deploy successfully.

  How much RAM is used at max for Java Heap can be easily adjusted by using the
  JVM option ``-XX:MaxRAMPercentage=xx.x``. For your convenience this has been
  simplified by supporting an environment variable ``${MEM_MAX_RAM_PERCENTAGE}``,
  see hidden example below. *Please keep in mind: value must be a floating point
  value!*

  .. toggle-header::
    :header: Development values are hidden on purpose to avoid confusion. *Expand/hide*

    1.5 GiB RAM means ~1 GiB of heap space using the 70% default setting, which is safe.
    You can tweak the setting to match your necessities like below:

    .. code-block:: yaml

      spec:
        template:
          spec:
            containers:
              - name: dataverse
                resources:
                  requests:
                    memory: "1.0Gi"
                  limits:
                    memory: "1.5Gi"
                env:
                  - name: MEM_MAX_RAM_PERCENTAGE
                    value: "50.0"

Fighting "Out Of Memory" situations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Java Memory usage is a very complex topic and you should take great care of
monitoring it's usage within your deployment.

Most operators are aware of the *Heap*, where values of POJOs are stored during
the applications runtime. You should also be aware of the *Stack*, *Metaspace*
and other memory terms, like *Native Memory*.

The following sections is not so much about prevention of these situations
(that's why you're doing monitoring, right?), but what you can do to troubleshoot
when bad things happened.



Shortage of Heap Space
......................

Many times, you're application is killed by running out of memory. Often this is
related to running out of *Heap Space*, the most important type of memory for a
Java application.

If you don't know what *Garbage Collection* is and how memory allocation works
in Java, you can find lots of resources online. Some examples:

- https://www.baeldung.com/java-stack-heap
- https://www.baeldung.com/jvm-garbage-collectors
- https://www.youtube.com/watch?v=kR8_r3kMK-Y

When running out of *Heap Space*, your JVM will throw an ``OutOfMemoryError``
exception (see also `Oracle docs on OutOfMemoryError`_).

In these cases, a *heap dump* will be written to ``$DUMPS_DIR``, which is
``/dumps`` by default. Those can be analyzed using tools like `Eclipse MAT`_.

.. note::
  In the ``dev`` persona, a sidecar container is deployed with whom you
  can use ``kubectl cp`` to download the ``.hprof`` dump file for analysis.

You might want to deploy your own solution, maybe uploading to an object store,
sending notifications or other great ideas. Some inspirations:

- https://link.medium.com/Ifnt4khj68
- https://link.medium.com/gZfpnGTH48
- https://danlebrero.com/2018/11/20/how-to-do-java-jvm-heapdump-in-kubernetes



Shortage of other memory spaces
...............................
For many users of Java applications, other types of memory than the *Heap* are
less commonly known. Compared to the huge amounts of Heap spaces, those are
often rather small, yet they might get you into trouble.

To understand how this might happen, you need to be aware that the Linux kernel
will non-gracefully kill processes exceeding their memory limits. A container
running on a Kubernetes cluster usually should have resource limits restrictions
applied. (Java will align it's memory usage to these as outlined above.) Once
the containers starts using more RAM than the limits allow, the out of memory
killer will stop the process (usually the only one running in a single container)
and Kubernetes will log an event ``OOMKilled``.

Depending on how much RAM budget you have left on your nodes, you might either
simply raise the limits. Or you might want to do deeper analysis of the problem,
because there might be a memory leak, coming back no matter how much you raise
the limits.

There are some excellent resources to read when you go for a hunt:

- https://devcenter.heroku.com/articles/java-memory-issues
- https://stackoverflow.com/questions/38597965
- https://medium.com/swlh/native-memory-the-silent-jvm-killer-595913cba8e7

So regarding to monitoring, you should always keep an eye not only on heap
and GC stats, but also on the very basic containers metrics offered by K8s.
Try to match the JVM memory stats with those from the container. If things
fall apart, there is a good chance you'll see it before it dies from memory leaks.




.. _Oracle docs on OutOfMemoryError: https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/memleaks002.html
.. _Eclipse MAT: https://www.eclipse.org/mat/
