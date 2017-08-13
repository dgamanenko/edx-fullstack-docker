#!/usr/bin/env bash

# NOTE (CCB): We do NOT call provision-ida because it expects a virtualenv.
# The new images for Credentials do not use virtualenv.

name=$IDA_NAME
port=$IDA_PORT

docker-compose $DOCKER_COMPOSE_FILES up -d $name

#Run syslog
docker exec edx.fullstack.${name} bash -c '/etc/init.d/rsyslog start && /bin/sleep 10' -- "$name"

echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker exec edx.fullstack.${name} bash -c 'source /edx/app/$1/$1_env && python /edx/app/$1/$1/manage.py migrate --settings=$1.settings.production' -- "$name"

echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker exec edx.fullstack.${name}  bash -c 'source /edx/app/$1/$1_env && cd /edx/app/$1/$1 && echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"staff\", \"staff@example.com\", \"edx\") if not User.objects.filter(username=\"staff\").exists() else None" | python manage.py shell' -- "$name"

# Create ${name} oauth2 client
# ./provision-ida-user.sh ${name} ${port}

if [ "$UPDATE_ASSETS" == 1 ]; then
    echo -e "${GREEN}Compiling static assets for ${name}...${NC}"
    docker exec edx.fullstack.${name} bash -c 'source /edx/app/$1/$1_env && python /edx/app/$1/$1/manage.py collectstatic --noinput --settings=$1.settings.production' -- "$name"
fi