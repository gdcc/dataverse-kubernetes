.. warning::
  **tl;dr:** Just :doc:`take me to the quickstart demos <quickstart/index>`.

=====================================
The Dataverse Cloud & Container Guide
=====================================

This project aims at offering a new way to deploy, run and maintain a Dataverse
installation for any purpose on any kind of Kubernetes-based cloud infrastructure.
You can use it on your laptop, in your on-prem datacentre or public cloud.
With the power of `Kubernetes <http://kubernetes.io>`_, many scenarios are possible.

.. important::

  | This is a **community driven and supported project**, unsupported by `IQSS <https://www.iq.harvard.edu/>`_, Harvard.
  | Current main driver is `Forschungszentrum Jülich <http://www.fz-juelich.de>`_.
  |
  | If you need help, please :issue:`open an issue <new>` or
    find us on `IRC <https://kiwiirc.com/client/irc.freenode.net/?nick=dataverse_k8s_?#dataverse>`_ or Twitter.


.. image:: img/building-blocks.svg
    :height: 250px

Content: what can you do for me?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We provide you with simple to re-use Kubernetes objects as building blocks.
Those help with

- :doc:`deployments on day 1 <day1/index>`,
- :doc:`operations on day 2 <day2/index>` and
- :doc:`integrations on day 3 <day3/index>`.

And if you're into developing Dataverse, we offer an easy to use
:doc:`development setup approach <development/index>`.

We're also maintaining the :doc:`container images <images/index>` deployments
build upon.



Context: what is Dataverse?
^^^^^^^^^^^^^^^^^^^^^^^^^^^
`The dataverse project <http://dataverse.org>`_ describes itself as:

  | Dataverse is an open source web application to share, preserve, cite, explore,
  | and analyze research data. It facilitates making data available to others, and
  | allows you to replicate others' work more easily. Researchers, journals, data
  | authors, publishers, data distributors, and affiliated institutions all receive
  | academic credit and web visibility.


.. toctree::
    :maxdepth: 4
    :hidden:

    quickstart/index
    day1/index
    day2/index
    day3/index
    images/index
    development/index
