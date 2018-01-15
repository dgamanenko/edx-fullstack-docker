#docker build -f build/edxapp/Dockerfile . -t raccoongang/edxapp-ginkgo-rg:latest --build-arg OPENEDX_RELEASE=ginkgo-rg

FROM ubuntu:16.04
MAINTAINER dgamanenko
USER root

RUN apt-get update && \  
      apt-get -y install sudo git gcc libffi-dev libssl-dev python-pip nginx tar libmysqlclient-dev language-pack-en python-virtualenv build-essential software-properties-common curl git-core libxml2-dev libxslt1-dev python-apt python-dev libxmlsec1-dev libfreetype6-dev swig g++ nodejs-legacy gettext gfortran graphviz graphviz-dev libffi-dev libfreetype6-dev libgeos-dev libjpeg8-dev liblapack-dev libpng12-dev libxml2-dev libxmlsec1-dev libxslt1-dev nodejs npm ntp pkg-config rsyslog && \
      pip install pyOpenSSL virtualenv azure  && \
      pip install --upgrade --user setuptools pip && \
      pip install ansible==2.3.2.0 boto==2.48.0 boto3==1.4.4 botocore==1.5.95 s3transfer==0.1.10

RUN adduser edxapp --home /edx/app/edxapp --disabled-password --gecos '' && usermod -a -G sudo edxapp

ARG OPENEDX_RELEASE=ginkgo-rg
ENV OPENEDX_RELEASE=${OPENEDX_RELEASE}

RUN git clone https://github.com/raccoongang/edx-platform.git -b ${OPENEDX_RELEASE} /edx/app/edxapp/edx-platform --depth=1
WORKDIR /edx/app/edxapp/edx-platform

RUN virtualenv /edx/app/edxapp/venvs/edxapp && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install git+https://github.com/edx/nltk.git@2.0.6#egg=nltk==2.0.6 && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/pre.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/base.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/local.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/github.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/edx-private.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/paver.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/pip install -r ./requirements/edx/post.txt && \
      /edx/app/edxapp/venvs/edxapp/bin/nodeenv /edx/app/edxapp/nodeenvs/edxapp --node=6.11.1 --prebuilt --force && \
      /edx/app/edxapp/venvs/edxapp/bin/paver install_prereqs

RUN adduser sandbox --home /edx/app/edxapp/venvs/edxapp-sandbox --disabled-password --gecos '' && usermod -a -G sudo sandbox

RUN virtualenv /edx/app/edxapp/venvs/edxapp-sandbox && \
      /edx/app/edxapp/venvs/edxapp-sandbox/bin/pip install -r ./requirements/edx-sandbox/base.txt && \
      /edx/app/edxapp/venvs/edxapp-sandbox/bin/pip install -r ./requirements/edx-sandbox/local.txt && \
      /edx/app/edxapp/venvs/edxapp-sandbox/bin/pip install -r ./requirements/edx-sandbox/post.txt && \
      chown -R sandbox:sandbox /edx/app/edxapp/venvs/edxapp-sandbox

RUN mkdir -p /edx/var/edxapp/staticfiles && \
      mkdir -p /edx/var/edxapp/media
RUN chown edxapp:www-data /edx/var/edxapp

RUN mkdir -p /edx/var/edxapp/media/grades && \
      chown www-data:www-data /edx/var/edxapp/media/grades
