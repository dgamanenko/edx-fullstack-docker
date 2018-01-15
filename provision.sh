#!/usr/bin/env bash

set -e
set -o pipefail
set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

if [ -z "$RUN_MIGRATINS" ] || [ "$RUN_MIGRATINS" == '' ]; then
	RUN_MIGRATINS=0
fi

if [ -z "$UPDATE_ASSETS" ] || [ "$UPDATE_ASSETS" == '' ]; then
	UPDATE_ASSETS=1
fi

if [ -z "$DB_PROVISION" ] || [ "$DB_PROVISION" == '' ]; then
	DB_PROVISION=1
fi

# Bring the databases online.
docker-compose $DOCKER_COMPOSE_FILES up -d mysql mongo

. mysql.env

# Ensure the MySQL server is online and usable
echo "Waiting for MySQL"
until docker exec -i edx.fullstack.mysql mysql -uroot -p$MYSQL_ROOT_PASSWORD -se "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'root')" &> /dev/null
do
  printf "."
  sleep 5
done

# In the event of a fresh MySQL container, wait a few seconds for the server to restart
# This can be removed once https://github.com/docker-library/mysql/issues/245 is resolved.
sleep 20

echo -e "MySQL ready"

if [ "$DB_PROVISION" == 1 ]; then
  echo -e "${GREEN}Creating databases and users...${NC}"
  #docker exec -i edx.fullstack.mysql mysql -uroot -p$MYSQL_ROOT_PASSWORD mysql < provision.sql
  docker run --rm --volumes-from edx.fullstack.mysql -v $(pwd)/.dev/backups:/backup debian:jessie tar zxvf /backup/mysql.tar.gz
  docker-compose restart mysql
  sleep 5
  docker exec -i edx.fullstack.mongo mongo < mongo-provision.js
else
	if [ "$DB_USER_PROVISION_ONLY" == 1 ]; then
	  docker exec -i edx.fullstack.mysql mysql -uroot -p$MYSQL_ROOT_PASSWORD mysql < mysql_dbs_and_users.sql
      docker exec -i edx.fullstack.mongo mongo < mongo-provision.js
	fi
fi


# IDA_NAME="programs" IDA_PORT="18140" ./provision-ida.sh
# IDA_NAME="credentials" IDA_PORT="18150" ./provision-ida.sh

./provision-lms.sh

# ./provision-ida-user.sh programs 18140
# ./provision-ida-user.sh credentials 18150

./provision-cms.sh

./provision-xqueue.sh

./provision-elasticsearch.sh

# Bring the nginx online.
docker-compose $DOCKER_COMPOSE_FILES up -d nginx

# ./provision-discovery.sh

echo -e "${GREEN}Provisioning complete!${NC}"
