
FROM python:2.7
MAINTAINER dgamanenko

# Some stuff that everyone has been copy-pasting
# since the dawn of time.
ENV PYTHONUNBUFFERED 1

RUN apt-get update
RUN apt-get install -y swig libssl-dev dpkg-dev netcat

COPY ./demoapp /provision

WORKDIR /provision

# Install requirements.
RUN pip install -U pip
RUN pip install -Ur requirements.txt

USER root 
