.DEFAULT_GOAL := help

FULLSTACK_WORKSPACE ?= ./workspace

OS := $(shell uname)

export FULLSTACK_WORKSPACE

export DOCKER_CLIENT_TIMEOUT=240
export COMPOSE_HTTP_TIMEOUT=240

DOCKER_COMPOSE_FILES_ALL=-f docker-compose.yml -f docker-compose-host.yml -f docker-compose-workers.yml -f docker-compose-workers-host.yml

DOCKER_COMPOSE_FILES_ALL_RUN=-f docker-compose.yml -f docker-compose-host.yml -f docker-compose-lms-run.yml -f docker-compose-cms-run.yml -f docker-compose-workers.yml -f docker-compose-workers-host.yml

# include *.mk

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## Display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

dev.requirements: ## Install requirements
	virtualenv $(FULLSTACK_WORKSPACE)/venv
	$(FULLSTACK_WORKSPACE)/venv/bin/pip install -r requirements.txt

travis.requirements: ## Install travis requirements
	pip install -r travis.requirements.txt

dev.update.configs: | dev.requirements ## Update OpeEdx and services configuration files
	ANSIBLE_CONFIG=./ansible.cfg $(FULLSTACK_WORKSPACE)/venv/bin/ansible-playbook -c local -i ",localhost" ansible-update-edxapp-configs.yml -e@configs/server-vars.yml --tags 'docker:configs' --syntax-check
	ANSIBLE_CONFIG=./ansible.cfg $(FULLSTACK_WORKSPACE)/venv/bin/ansible-playbook -c local -i ",localhost" ansible-update-edxapp-configs.yml -e@configs/server-vars.yml --tags 'docker:configs'

dev.clone: ## Clone service repos to the parent directory
	./clone.sh

dev.provision.run: # Provision all services with local mounted directories
	DB_PROVISION=1 RUN_MIGRATINS=0 DB_USER_PROVISION_ONLY=0 UPDATE_ASSETS=1 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.provision: | dev.provision.run stop ## Provision dev environment with all services stopped

dev.provision-nodbupdate.run: # Provision all services with local mounted directories
	DB_PROVISION=0 RUN_MIGRATINS=0 DB_USER_PROVISION_ONLY=0 UPDATE_ASSETS=1 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.provision-nodbupdate: | dev.provision-nodbupdate.run stop ## Provision dev environment with all services stopped

dev.provision-noassets.run: # Provision all services with local mounted directories without lms and cms update assets
	DB_PROVISION=1 RUN_MIGRATINS=0 DB_USER_PROVISION_ONLY=0 UPDATE_ASSETS=0 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.provision-noassets: | dev.provision-noassets.run stop ## Provision dev environment with all services stopped without lms and cms update assets

dev.migrate-provision-noassets.run: # Provision all services with local mounted directories (with full django migrations instead of using sql dumps and without lms and cms update assets)
	DB_PROVISION=1 RUN_MIGRATINS=1 DB_USER_PROVISION_ONLY=0 UPDATE_ASSETS=0 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.migrate-provision-noassets: | dev.migrate-provision-noassets.run stop ## Provision dev environment with all services stopped (with full django migrations instead of using sql dumps and without lms and cms update assets)

dev.migrate-provision.run: # Provision all services with local mounted directories (with full django migrations instead of using sql dumps)
	 DB_PROVISION=1 RUN_MIGRATINS=1 DB_USER_PROVISION_ONLY=0 UPDATE_ASSETS=1 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.migrate-provision: | dev.migrate-provision.run stop ## Provision dev environment with all services stopped (with full django migrations instead of using sql dumps)

dev.up: | dev.update.configs ## Bring up all services (except workers) with host volumes
	docker-compose -f docker-compose.yml -f docker-compose-host.yml -f docker-compose-lms-run.yml -f docker-compose-cms-run.yml up -d

dev.fullstack.up: ## Bring up all services (including workers) with host volumes
	make dev.up
	sleep 120
	docker-compose -f docker-compose.yml -f docker-compose-host.yml -f docker-compose-lms-run.yml -f docker-compose-cms-run.yml -f docker-compose-workers.yml -f docker-compose-workers-host.yml up -d

provision: ## Provision all services using the Docker volume
	DB_PROVISION=1 RUN_MIGRATINS=0 DB_USER_PROVISION_ONLY=0 UPDATE_ASSETS=1 ./provision.sh

stop: ## Stop all services
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) stop

down: ## Remove all service containers and networks
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) down

destroy: ## Remove all fullstack-related containers, networks, and volumes
	DOCKER_COMPOSE_FILES="$(DOCKER_COMPOSE_FILES_ALL)" ./destroy.sh

logs: ## View logs from containers running in detached mode
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) logs -f

pull: ## Update Docker images
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) pull

validate: ## Validate the fullstack configuration
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) config

backup: ## Write all data volumes to the host.
	docker run --rm --volumes-from edx.fullstack.mysql -v $$(pwd)/.dev/backups:/backup debian:jessie tar zcvf /backup/mysql.tar.gz /var/lib/mysql
	docker run --rm --volumes-from edx.fullstack.mongo -v $$(pwd)/.dev/backups:/backup debian:jessie tar zcvf /backup/mongo.tar.gz /data/db
	docker run --rm --volumes-from edx.fullstack.elasticsearch -v $$(pwd)/.dev/backups:/backup debian:jessie tar zcvf /backup/elasticsearch.tar.gz /usr/share/elasticsearch/data

restore:  ## Restore all data volumes from the host. WARNING: THIS WILL OVERWRITE ALL EXISTING DATA!
	docker run --rm --volumes-from edx.fullstack.mysql -v $$(pwd)/.dev/backups:/backup debian:jessie tar zxvf /backup/mysql.tar.gz
	docker run --rm --volumes-from edx.fullstack.mongo -v $$(pwd)/.dev/backups:/backup debian:jessie tar zxvf /backup/mongo.tar.gz
	docker run --rm --volumes-from edx.fullstack.elasticsearch -v $$(pwd)/.dev/backups:/backup debian:jessie tar zxvf /backup/elasticsearch.tar.gz

%-shell: ## Run a shell on the specified service container
	docker exec -it edx.fullstack.$* env TERM=$(TERM) bash

lms-shell: ## Run a shell on the LMS container
	docker exec -it edx.fullstack.lms env TERM=$(TERM) bash

cms-shell: ## Run a shell on the Studio container
	docker exec -it edx.fullstack.studio env TERM=$(TERM) bash

%-start: ## Start a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL_RUN) start $*

%-stop: ## Stop a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL_RUN) stop $*

%-restart: ## Restart a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL_RUN) restart $*

%-up: ## Bring up a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL_RUN) up -d $*

lms.assets: ## Update LMS assets
	    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && cd /edx/app/edxapp/edx-platform && paver update_assets lms --settings aws'

cms.assets: ## Update CMS assets
	    docker-compose exec studio bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && cd /edx/app/edxapp/edx-platform && paver update_assets cms --settings aws'

%-ida.assets: ## Update ida assets
	docker-compose exec $* bash -c 'source /edx/app/$*/$*_env && python /edx/app/$*/$*/manage.py collectstatic --noinput --settings=$*.settings.production'

healthchecks: ## Run a curl against all services' healthcheck endpoints to make sure they are up. This will eventually be parameterized
	./healthchecks.sh

validate-lms-volume: ## Validate that changes to the local workspace are reflected in the LMS container
	touch $(FULLSTACK_WORKSPACE)/edx-platform/testfile
	docker exec edx.fullstack.lms ls /edx/app/edxapp/edx-platform/testfile
	rm $(FULLSTACK_WORKSPACE)/edx-platform/testfile

