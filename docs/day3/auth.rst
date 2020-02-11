=======================
External Authentication
=======================

For a serious production installation, you will want to provide not only
builtin users, but integrate Dataverse with existing authentication providers
run by your corporation or firms like ORCID, GitHub, Google etc.

Upstream documentation names a few possibilities:

- `OpenID Connect <http://guides.dataverse.org/en/latest/installation/oidc.html>`_
- `OAuth2 <http://guides.dataverse.org/en/latest/installation/oauth2.html>`_
- `Shibboleth <http://guides.dataverse.org/en/latest/installation/shibboleth.html>`_

Below you can find a description how to use them within a Kubernetes deployment.



OAuth2 and OpenID Connect providers
-----------------------------------

The linked Dataverse installation guide sections above already explain the back
and forth plus differences between the two related options. In terms of
configuration they are rather similar, so lets head over.

Authentication providers are configured via JSON objects in Dataverse, being
pushed to an API endpoint to configure and enable.

While you could simply deploy your authentication provider configuration
manually, this is not sustainable nor follow it best practices like GitOps and
DevOps.

To store and deploy the configuration in a secure and sustainable way, we do the
following:

.. uml::

  @startuml
  (*) --> "Create provider JSON objects"
  --> "Split off secrets from configuration"
  --> ===B1===
  --> "Replace secrets in JSON with\n//esh// template codes"
  --> "Create K8s Secrets for any\nClient ID and Client Secret"
  --> ===B2===
  ===B1=== --> "Add JSON array of providers\nin Dataverse ConfigMap"
  --> "Store in revision control,\nDeploy to cluster"
  --> ===B2===
  --> "Let configuration K8s Job merge\n again and push into Dataverse"
  --> (*)
  @enduml

Add providers to ``ConfigMap``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To create a configuration usable in your Kubernetes deployment, simply add them
to your ``ConfigMap`` as shown in the below example.

Again, please make yourself familiar with upstream documentation about
`OpenID Connect <http://guides.dataverse.org/en/latest/installation/oidc.html>`_
and `OAuth2 <http://guides.dataverse.org/en/latest/installation/oauth2.html>`_.

.. literalinclude:: examples/auth-provider-configmap.yaml
    :name: auth-provider-configmap
    :language: yaml
    :emphasize-lines: 7,14,22

.. important::

  1. You need to provide your JSON array of providers as ``AUTH_PROVIDERS``
     key, otherwise the configuration script cannot find them.
  2. Split off the secret values for ``clientId`` and ``clientSecret``. See below.

Add ``Secret``\ s for credentials
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Now let's create a secret with all our shiny access credentials for the external
authentication services we use. Please remember to read :doc:`/day1/secrets`,
too, to be on the safe side with your confidential data.

.. literalinclude:: examples/auth-provider-secret.yaml
    :name: auth-provider-secret
    :language: yaml

Align ``Job``\ s, ``Secret`` and ``ConfigMap`` for merging
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Our ``Job`` Kubernetes objects for configuring and bootstrapping Dataverse by
default try to mount the ``dataverse-providers`` secret at ``$SECRET_DIR/providers``
(see also :ref:`dataverse-k8s image <images/dataverse-k8s:Secrets and Credentials>`), but do it optionally.

The configuration job uses `esh <https://github.com/jirutka/esh>`_ to merge back
the secret values into the JSON provider objects from the ``ConfigMap``. We
simply read the values from the secret files mounted by Kubernetes and push
the merged provider configurations to Dataverse with ``curl``.

So make sure that your file path to the secret files match with the key values
in your secret. See matching example above.

.. hint::
  As always, your ``Secret``\ s should be mounted as volumes. We consider this
  as a safe default and will only support this kind of usage.



SAML using Shibboleth Service Provider
--------------------------------------
Many institutes from R&D and higher education are part of the worldwide SAML-based
`edugain AAA federation <https://edugain.org>`_.

While this is a great idea, there are two problems:

A federation design drawback: Dataverse relies completely on the fact that the
SAML identity provider will provide all attributes like names, email etc.
This is not always the case within the federation, depending on the decisions
taken in the individual institutions. There are guidelines, but in real life,
things are tough and admins don't have lots of resources for remote partners.
See also https://wiki.geant.org/display/eduGAIN/IDP+Attribute+Profile+and+Recommended+Attributes

.. container:: left-col

   Shibboleth is perfectly suited for use as an identity provider.

   Running it as a service provider for Dataverse on a Kubernetes deployment is
   a bad idea. It violates best practices of one service per container and locks
   you into an Apache-based reverse proxy. You will want to avoid that by all
   means on Kubernetes cluster.

   Please find us on IRC to discuss further.

.. container:: right-col

  .. thumbnail:: img/cato-shibboleth.jpg
       :width: 25%

SAML using an Identity Management Service
-----------------------------------------
Please see above for OpenID Connect support hooking into Dataverse to attach
to such services integrated in SAML federations.
