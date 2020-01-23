==========
Monitoring
==========

This section of the guide is about presenting some ideas how you could enable
monitoring for your running Dataverse application. Some modern monitoring
systems are supported, as always, on a community basis. Feel free to extend.

Monitoring Dataverse application server
---------------------------------------
Easiest way forward is by using `Prometheus <https://prometheus.io>`_. The
:doc:`/images/dataverse-k8s` ships with the
`official JMX exporter <https://github.com/prometheus/jmx_exporter>`_, which
allows you to monitor the complete JVM statistics as necessary.

Enable JMX exports
^^^^^^^^^^^^^^^^^^

JMX exporter Java agent is included and started by the JVM when booting the
container and enabled. To enable, modify your ``ConfigMap`` (see also
:doc:`/day1/config`).

.. code-block:: yaml

  # ...
  data:
    ENABLE_JMX_EXPORT: "1"

By default, the agent is reachable at port ``8081`` and uses the default ``{}``
configuration as suggested by upstream. You can override the listening
port via environment variable and configuration via mounting a file.

.. code-block:: yaml

  # ...
  data:
    ENABLE_JMX_EXPORT: "1"
    JMX_EXPORTER_PORT: "12345"
    JMX_EXPORTER_CONFIG: "/my/place/where/i/mounted/config.yaml"

.. note::

  You can put your config in some ``ConfigMap`` and mount  as a file.
  Examples can be found on the internet, e. g. at https://carlos.mendible.com/2019/02/10/kubernetes-mount-file-pod-with-configmap
