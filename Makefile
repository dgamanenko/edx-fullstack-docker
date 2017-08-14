.DEFAULT_GOAL := help

FULLSTACK_WORKSPACE ?= ..

OS := $(shell uname)

export FULLSTACK_WORKSPACE

export DOCKER_CLIENT_TIMEOUT=240
export COMPOSE_HTTP_TIMEOUT=240

DOCKER_COMPOSE_FILES_ALL=-f docker-compose.yml -f docker-compose-host.yml -f docker-compose-workers.yml -f docker-compose-workers-host.yml

# include *.mk

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## Display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

requirements: ## Install requirements
	pip install -r requirements.txt

dev.clone: ## Clone service repos to the parent directory
	./clone.sh

dev.provision.run: ## Provision all services with local mounted directories
	DB_PROVISION=1 RUN_MIGRATINS=0 UPDATE_ASSETS=1 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.provision: | dev.provision.run stop ## Provision dev environment with all services stopped

dev.provision-nodbupdate.run: ## Provision all services with local mounted directories
	DB_PROVISION=0 RUN_MIGRATINS=0 UPDATE_ASSETS=1 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.provision-nodbupdate: | dev.provision-nodbupdate.run stop ## Provision dev environment with all services stopped

dev.provision-noassets.run: ## Provision all services with local mounted directories without lms and cms update assets
	DB_PROVISION=1 RUN_MIGRATINS=0 UPDATE_ASSETS=0 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.provision-noassets: | dev.provision-noassets.run stop ## Provision dev environment with all services stopped without lms and cms update assets

dev.migrate-provision-noassets.run: ## Provision all services with local mounted directories (with full django migrations instead of using sql dumps and without lms and cms update assets)
	DB_PROVISION=1 RUN_MIGRATINS=1 UPDATE_ASSETS=0 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.migrate-provision-noassets: | dev.migrate-provision-noassets.run stop ## Provision dev environment with all services stopped (with full django migrations instead of using sql dumps and without lms and cms update assets)

dev.migrate-provision.run: ## Provision all services with local mounted directories (with full django migrations instead of using sql dumps)
	 DB_PROVISION=1 RUN_MIGRATINS=1 UPDATE_ASSETS=1 DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision.sh

dev.migrate-provision: | dev.migrate-provision.run stop ## Provision dev environment with all services stopped (with full django migrations instead of using sql dumps)

dev.up: ## Bring up all services (except workers) with host volumes
	docker-compose -f docker-compose.yml -f docker-compose-host.yml up -d

dev.fullstack.up: ## Bring up all services (including workers) with host volumes
	make dev.up
	sleep 120
	docker-compose -f docker-compose.yml -f docker-compose-host.yml -f docker-compose-workers.yml -f docker-compose-workers-host.yml up -d

provision: ## Provision all services using the Docker volume
	DB_PROVISION=1 RUN_MIGRATINS=0 UPDATE_ASSETS=1 ./provision.sh

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

# TODO: Print out help for this target. Even better if we can iterate over the
# services in docker-compose.yml, and print the actual service names.
%-shell: ## Run a shell on the specified service container
	docker exec -it edx.fullstack.$* env TERM=$(TERM) /edx/app/$*/fullstack.sh open

lms-shell: ## Run a shell on the LMS container
	docker exec -it edx.fullstack.lms env TERM=$(TERM) /edx/app/edxapp/fullstack.sh open

studio-shell: ## Run a shell on the Studio container
	docker exec -it edx.fullstack.studio env TERM=$(TERM) /edx/app/edxapp/fullstack.sh open

%-start: ## Start a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) start $*

%-stop: ## Stop a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) stop $*

%-restart: ## Restart a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) restart $*

%-up: ## Restart a specified service container
	docker-compose $(DOCKER_COMPOSE_FILES_ALL) up -d $*

lms.assets: ## Update LMS assets
	    DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && paver update_assets lms --settings aws'

cms.assets: ## Update CMS assets
	    DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" docker-compose exec studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && paver update_assets cms --settings aws'

%-ida.assets: ## Update ida assets
	DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" docker-compose exec $* bash -c 'source /edx/app/$*/$*_env && python /edx/app/$*/$*/manage.py collectstatic --noinput --settings=$*.settings.production'

healthchecks: ## Run a curl against all services' healthcheck endpoints to make sure they are up. This will eventually be parameterized
	./healthchecks.sh

validate-lms-volume: ## Validate that changes to the local workspace are reflected in the LMS container
	touch $(FULLSTACK_WORKSPACE)/edx-platform/testfile
	docker exec edx.fullstack.lms ls /edx/app/edxapp/edx-platform/testfile
	rm $(FULLSTACK_WORKSPACE)/edx-platform/testfile
