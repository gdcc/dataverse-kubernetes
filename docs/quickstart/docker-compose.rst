==============================
Using *docker-compose* persona
==============================

.. hint::
  This is in a proof of concept stage. Enhance if you feel this is
  useful to you.

This persona is about setting up a demo environment very quickly with
installing `Docker`_ and `docker-compose`_ only.

Simply clone the project to any directory and execute

.. code-block:: shell

  docker-compose up

This will build all images necessary and deploy the application.
Once deployment is done (you'll see in the logs when auto deploy worked),
you'll need to bootstrap the database:

.. code-block:: shell

  docker-compose run --no-deps --rm dataverse scripts/bootstrap-job.sh

Then you can access Dataverse at http://localhost:8080 and login
with the default ``dataverseAdmin:admin1``. Enjoy!



.. _Docker: https://docs.docker.com/install
.. _docker-compose: https://docs.docker.com/compose/install
