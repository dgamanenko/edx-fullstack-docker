set -e
set -o pipefail
set -x

# Bring CMS online
docker-compose $DOCKER_COMPOSE_FILES up -d studio

# docker-compose exec studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && NO_PYTHON_UNINSTALL=1 paver install_prereqs'

# #Installing prereqs crashes the process
# docker-compose restart studio

# Run syslog
docker-compose exec studio bash -c '/etc/init.d/rsyslog start && /bin/sleep 10'

if [ "$RUN_MIGRATINS" == 1 ]; then
    # Run edxapp cms migrations
    echo -e "${GREEN}Run edxapp cms migrations"
    docker-compose exec studio bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py cms migrate --settings=aws'
fi

if [ "$UPDATE_ASSETS" == 1 ]; then
    # Update CMS Assets
    echo -e "${GREEN}Update CMS Assets"
    docker-compose exec studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && paver update_assets cms --settings aws'
fi