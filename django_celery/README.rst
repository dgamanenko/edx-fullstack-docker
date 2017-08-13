==============================================================
 Example Django project using Celery
==============================================================

Contents
========

``dockercelery/``
---------

This is a project in itself, created using
``django-admin.py startproject dockercelery``, and then the settings module
(``dockercelery/settings.py``) was modified to add ``dockerprovision`` to
``INSTALLED_APPS``

``dockercelery/celery.py``
----------

This module contains the Celery application instance for this project,
we take configuration from Django settings and use ``autodiscover_tasks`` to
find task modules inside all packages listed in ``INSTALLED_APPS``.

``dockerprovision/``
------------

Example app.  This is decoupled from the rest of the project by using
the ``@shared_task`` decorator.  This decorator returns a proxy that always
points to the currently active Celery instance.

Installing requirements
=======================

The settings file assumes that ``rabbitmq-server`` is running on ``localhost``
using the port 25672. rabbitmq docker container (in our case):

.. code-block:: console
    $ cd django_celery/
    $ docker-compose -f docker-compose.yml up -d

Python requirements must be satisfied:

.. code-block:: console

    $ virtualenv venv
    $ source venv/bin/activate
    $ pip install -r requirements.txt

Starting the worker
===================

.. code-block:: console

    $ cd dockerprovision/
    $ celery worker --app=dockercelery.celery:app --loglevel=INFO

Running a task
===================

.. code-block:: console

    $ python ./manage.py shell
    >>> from dockerprovision.tasks import makeTask
    >>> t=makeTask(Makefile='/Users/dgamanenko/devstack/docker-fullstack/fullstack/Makefile', make_param='dev.up')

