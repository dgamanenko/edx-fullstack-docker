===========================
OpenEdX Fullstack |Build Status|
===========================

Get up and running quickly with edX services.

If you are seeking infoedX on the Vagrant-based fullstack, please see
https://openedx.atlassian.net/wiki/display/OpenOPS/Running+fullstack. This
project is meant to replace the traditional Vagrant-based fullstack with a
multi-container approach driven by `Docker Compose`_. It is still in the
alpha/beta testing phase. Support for this project is limited at the moment, so
it may take a while to respond to issues.

You should run any Make targets described below on your local machine, *not*
from within a VM.


Getting Started
---------------

All of the services can be run by following the steps below. Note that since we
are running many containers, you should configure Docker with a sufficient
amount of resources. Our testing found that `configuring Docker for Mac`_ with
a minimum of 2 CPUs and 4GB of memory works well.

1. The Docker Compose file mounts a host volume for each service's executing
   code. The host directory is defaults to be a sibling of this directory. For
   example, if this repo is cloned to ``~/workspace/fullstack``, host volumes
   will be expected in ``~/workspace/edx-platform``, etc. These repos can be cloned with the command
   below.

   .. code:: sh

       make dev.clone

   You may customize where the local repositories are found by setting the
   fullstack\_WORKSPACE environment variable.

2. Run the provision command, if you haven't already, to configure the various
   services with superusers (for development without the auth service) and
   tenants (for multi-tenancy).

   The username and password for the superusers are both "edx". You can access
   the services directly via Django admin at the ``/admin/`` path, or login via
   single sign-on at ``/login/``.

   Provision

   .. code:: sh

       make dev.provision

3. Start the services. This command will mount the repositories under the
   fullstack\_WORKSPACE directory.

   *Note: it may take up to 60 seconds for the LMS to start*

   Start

   .. code:: sh

       make dev.fullstack.up

       # to start without lms and cms workers use:
       make dev.up

After the services have started, if you need shell access to one of the
services, run ``make <service>-shell``. For example to access the
Catalog/Course Discovery Service, you can run:

.. code:: sh

    make lms-shell

To see logs from containers running in detached mode, you can either use
"Kitematic" (available from the "Docker for Mac" menu), or by running the
following:

.. code:: sh

    make logs

To reset your environment and start provisioning from scratch, you can run:

.. code:: sh

    make destroy

To start/restart/up/stop some of container use:

.. code:: sh

    make %-start:
    
    # for example: 
    make lms-start

-----------------------

The provisioning script creates a Django superuser for every service.

::

    Email: edx@example.com
    Username: edx
    Password: edx

The LMS also includes demo accounts. The passwords for each of these accounts
is ``edx``.

+------------+------------------------+
| Username   | Email                  |
+============+========================+
| audit      | audit@example.com      |
+------------+------------------------+
| honor      | honor@example.com      |
+------------+------------------------+
| staff      | staff@example.com      |
+------------+------------------------+
| verified   | verified@example.com   |
+------------+------------------------+

Service URLs
------------

Each service is accessible at ``localhost`` on a specific port. The table below
provides links to the homepage of each service. Since some services are not
meant to be user-facing, the "homepage" may be the API root.

+---------------------+-------------------------------------+
| Service             | URL                                 |
+=====================+=====================================+
| LMS                 | http://localhost:18000/             |
+---------------------+-------------------------------------+
| Studio/CMS          | http://localhost:18010/             |
+---------------------+-------------------------------------+

Useful Commands
---------------

Sometimes you may need to restart a particular application server. To do so,
simply use the ``docker-compose restart`` command:

.. code:: sh

    docker-compose restart <service>

``<service>`` should be replaced with one of the following:


-  lms
-  studio

How do I build images?
----------------------

We are still working on automated image builds, but generally try to push new
images every 3-7 days. If you want to build the images on your own, the
Dockerfiles are available in the ``edx/configuration`` repo.

NOTES

1. edxapp is the only service whose changes have been merged to the master
   branch.
2. edxapp uses the ``latest`` tag. All other services use the ``fullstack`` tag.

.. code:: sh

    git checkout master
    git pull
    docker build -f docker/build/edxapp/Dockerfile . -t edxops/edxapp:latest

.. code:: sh

    git checkout clintonb/docker-fullstack-idas
    git pull
    docker build -f docker/build/forum/Dockerfile . -t edxops/discovery:fullstack

The build commands above will use your local configuration, but pull
application code from the master branch of the application's repository. If you
would like to use code from another branch/tag/hash, modify the ``*_VERSION``
variable that lives in the ``ansible_overrides.yml`` file beside the
``Dockerfile``.

For example, if you wanted to build tag ``release-2017-03-03`` for the
Course Discovery Service, you would modify ``forum_version`` (``forum_source_repo`` for use another remote) in
``docker/build/discovery/ansible_overrides.yml``.

Troubleshooting
---------------


If you are having trouble with your containers there are a few steps you can
take to try to resolve.

Update the code and images
~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure you have the latest code and Docker images. Run ``make pull`` in the
fullstack directory to pull the latest Docker images. We infrequently make
changes to the Docker Compose configuration and provisioning scripts. Run ``git
pull`` in the fullstack directory to pull the latest configuration and scripts.
The images are built from the ficus-rg branches of the application repositories.
Make sure you are using the latest code from the ficus-rg branches, or have
rebased your branches on ficus-rg.

Clean the containers
~~~~~~~~~~~~~~~~~~~

Sometimes containers end up in strange states and need to be rebuilt. Run
``make down`` to remove all containers and networks. This will NOT remove your
data volumes.

Start over
~~~~~~~~~

If you want to completely start over, run ``make destroy``. This will remove
all containers, networks, AND data volumes.


.. _Docker Compose: https://docs.docker.com/compose/
.. _Docker for Mac: https://docs.docker.com/docker-for-mac/
.. _configuring Docker for Mac: https://docs.docker.com/docker-for-mac/#/advanced

.. |Build Status| image:: https://travis-ci.org/dgamanenko/edx-fullstack-docker.svg?branch=master
   :target: https://travis-ci.org/dgamanenko/edx-fullstack-docker

