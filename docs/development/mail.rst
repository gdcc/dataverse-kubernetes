===========
Catch mails
===========

While doing a showcase, developing or other purposes, it comes in handy
to see what emails are sent by Dataverse.

Instead of relying on an external service as Mailinator, Mailtrap.io or similar,
just use `MailCatcher <https://mailcatcher.me>`_ as a small extra deployment:

.. code-block:: shell

  kubectl create -f k8s/utils/mailcatcher.yaml
  minikube service mailcatcher

(The last will open the web UI in your default browser.)

The SMTP server can be used via ``postfix:25``, which is also the default config
for Dataverse when you "just use" the deployments found in ``k8s/``. (It will
*"Just Work (TM)"*).

**Please note** that all sent mails will be **deleted** when you restart or
delete the deployment/pod/container.
