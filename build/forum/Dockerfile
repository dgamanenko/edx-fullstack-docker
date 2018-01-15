#docker build -f build/forum/Dockerfile . -t raccoongang/forum-ginkgo-rg:latest --build-arg forum_version=open-release/ginkgo.1

FROM ubuntu:16.04
MAINTAINER dgamanenko
USER root

RUN apt-get update && \  
      apt-get -y install sudo git gcc libffi-dev libssl-dev python-pip nginx tar libmysqlclient-dev language-pack-en python-virtualenv build-essential software-properties-common curl git-core libxml2-dev libxslt1-dev python-apt python-dev libxmlsec1-dev libfreetype6-dev swig g++ nodejs-legacy gettext gfortran graphviz graphviz-dev libffi-dev libfreetype6-dev libgeos-dev libjpeg8-dev liblapack-dev libpng12-dev libxml2-dev libxmlsec1-dev libxslt1-dev nodejs npm ntp pkg-config && \
      pip install pyOpenSSL virtualenv azure  && \
      pip install --upgrade --user setuptools pip && \
      pip install ansible==2.3.2.0 boto==2.48.0 boto3==1.4.4 botocore==1.5.95 s3transfer==0.1.10

#RUN adduser forum --home /edx/app/forum --disabled-password --gecos '' && usermod -a -G forum

#RUN mkdir -p /edx/var && \
#      chown www-data:www-data /edx/var

ARG forum_version=open-release/ginkgo.1
ENV forum_version=${forum_version}

RUN git clone https://github.com/edx/cs_comments_service.git -b ${forum_version} /edx/app/forum/cs_comments_service --depth=1
COPY ./configs/envs-edx/forum_env /edx/app/forum/forum_env
# && \
#      chown forum:www-data /edx/app/forum/forum_env
#RUN chown forum:www-data /edx/app/forum && \
#    chown -R forum:forum /edx/app/forum/cs_comments_service

WORKDIR /edx/app/forum/cs_comments_service && \
      bundle install --deployment --path /edx/app/forum/.gem

