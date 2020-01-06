=============
Configuration
=============

.. warning::

  | **DO. NOT. SET. ANY. PLAIN. PASSWORD. IN. ANY.** ``ConfigMap`` **.**
  | (Or ``Deployment``, ``Pod``, ...) Use ``Secrets`` for this. See :doc:`secrets`.

For usage on Kubernetes, all configuration can be stored in a ``ConfigMap``.

Configuring Dataverse is done in multiple ways:

#.  Database connection, mail gateway, bootstrap values, etc used in scripts
    are read from environment variables directly.

    * Use these variable names in your ``ConfigMap``.
    * See :ref:`default.config` for a list of these special ones.

#.  Things like file storage, networking, most DOI, etc are all *basic system settings*
    and can be set via Java system properties, residing in the Glassfish domain configuration.

    * See :ref:`JVM Options <jvm-options>` on how to configure these.
    * See `Dataverse Installation Guide: JVM options <http://guides.dataverse.org/en/latest/installation/config.html#jvm-options>`_
      for a complete list of all available options.

#.  More options are stored in the database and configured via API and/or UI.

    * See :ref:`Database Settings <database-settings>` on how to configure these.
    * See `Dataverse Installation Guide: Database settings <http://guides.dataverse.org/en/latest/installation/config.html#database-settings>`_
      for an exhaustive list of all available options.

.. note::

  All of this should be streamlined into an easier to use configuration system.
  See https://github.com/IQSS/dataverse/issues/5293 for more. Please leave a
  comment there if you feel the same.




.. _jvm-options:

System Properties: JVM options
------------------------------
The basic idea is to map environment variables to Java system properties each
time a Dataverse container starts with the default entrypoint (being the application
server).

1. Simply pick a `JVM option <http://guides.dataverse.org/en/latest/installation/config.html#jvm-options>`_
   from the list and replace "." with "_" ("-" is not allowed in env var names!).
2. Put the transformed name as a key into the ``ConfigMap.data``.
3. Add your value. Be sure to use simple strings only - no numbers, no complex types. Escape with ``" "``.

.. note::

  Currently many JVM options have dashes in them, which is no allowed character for
  an environment variable. As a workaround, replace any dash with ``__`` (double underscore).
  Will be transformed back into a ``-`` internally when the container starts. See example below.



Examples (see below :ref:`full-example`):

.. literalinclude:: examples/configmap.yaml
    :lines: 12,16-18,26-27,34


.. warning::

  **DO NOT USE THIS** ``ConfigMap`` **FOR PASSWORDS!** Those are done via Kubernetes ``Secrets``, see :doc:`secrets`.





.. _database-settings:

Database Options: Using ``curl``
--------------------------------

As database settings are persistent in, well, the database, they don't need
to get set everytime the container starts. To be consistent and easy to use,
the same `ConfigMap` used for JVM options can be used for these settings,
but you need to create a `Job` or even a `CronJob` to apply them.

.. note::

  Of course you can choose to use your own tools and scripts for this.
  Basically its just `curl` calls to the Admin API.

Provide settings
^^^^^^^^^^^^^^^^

1. Pick a `Database setting <http://guides.dataverse.org/en/latest/installation/config.html#database-settings>`_
2. Remove the ``:``` and replace it with ``db_``. Keep the Pascal case!
3. Put the transformed value into the ``ConfigMap.data``.
4. Add your value, which can be any value you see in the docs. Keep in mind:
   when you need to use JSON, format it as a string!
5. When you need to **delete** a setting, just provide an *empty* value.

Examples (see below :ref:`full-example`):

.. literalinclude:: examples/configmap.yaml
    :lines: 12,27-31,42-43

.. warning::

  **DO NOT USE THIS** ``ConfigMap`` **FOR PASSWORDS!** Those are done via Kubernetes ``Secrets``, see :doc:`secrets`.

Apply settings
^^^^^^^^^^^^^^
Remember: you will need to update your ``ConfigMap`` when you want to apply changes.
You need to think about in which file you keep the map - having it in two locations
is a bad idea. It's always a good idea to put it in revision control.

.. code::

  # Update ConfigMap:
  kubectl apply -f k8s/dataverse/configmap.yaml
  # Deploy a new config job:
  kubectl create -f k8s/dataverse/jobs/configure.yaml

You might consider providing a `CronJob` for scheduled, regular updates.

Alternative approaches
######################

There's also `stakater/Reloader <https://github.com/stakater/Reloader>`_, a tool
to auto-reload resources. To use it, you will need to 1) change metadata of
deployments (easy) and 2) change the image to include an entrypoint script that runs
the configuration script on boot (not so easy). Feel free to leave feedback in
the project if you are interested having this builtin.


.. _full-example:

Full configuration example
--------------------------

Below you can find an example ``ConfigMap`` using all three types of variables:

.. literalinclude:: examples/configmap.yaml
    :caption: configmap.yaml
    :name: configmap
    :language: yaml

Sane defaults: ``default.config``
---------------------------------

Some things need sane defaults, which can be found in :ref:`default.config` (see below).
You might find those usefull as an example for your personally tuned `ConfigMap`.

.. literalinclude:: ../../docker/dataverse-k8s/glassfish/bin/default.config
    :caption: default.config
    :name: default.config
    :language: shell
