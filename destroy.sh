#!/usr/bin/env bash

set -e

read -p "This will delete all data in your fullstack. Would you like to proceed? [y/n] " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo
    docker-compose $DOCKER_COMPOSE_FILES down -v
fi
