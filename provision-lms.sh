set -e
set -o pipefail
set -x


if [ "$RUN_MIGRATINS" == 0 ]; then
	if [ "$DB_PROVISION" == 1 ]; then
        # Load database dumps for the largest databases to save time
        echo -e "${GREEN}Load database dumps for the largest databases to save time"
        ./load-db.sh edxapp
        ./load-db.sh edxapp_csmh
    fi
fi
# Bring LMS online
docker-compose $DOCKER_COMPOSE_FILES up -d lms

docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && NO_PYTHON_UNINSTALL=1 paver install_prereqs'

#Installing prereqs crashes the process
docker-compose restart lms

# Run syslog
docker-compose exec lms bash -c '/etc/init.d/rsyslog start && /bin/sleep 10'

# Run edxapp migrations first since they are needed for the service users and OAuth clients
# docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && NO_PREREQ_INSTALL=1 paver update_db --settings aws'

if [ "$RUN_MIGRATINS" == 1 ]; then
    # Run edxapp lms migrations
    echo -e "${GREEN}Run edxapp lms migrations"
    docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms migrate --settings=aws'
fi

# Create a superuser for edxapp
docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws manage_user staff staff@example.com --superuser --staff'
docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username=\"staff\"); user.set_password(\"edx\"); user.save()" | python /edx/app/edxapp/edx-platform/manage.py lms shell  --settings=aws'

if [ "$DB_PROVISION" == 1 ]; then
    # Enable the LMS-E-Commerce integration
    echo -e "${GREEN}Enable the LMS-E-Commerce integration"
    docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws configure_commerce'

    # Create demo course and users
    echo -e "${GREEN}Create demo course and users"
    docker-compose exec lms bash -c '/edx/app/edx_ansible/venvs/edx_ansible/bin/ansible-playbook /edx/app/edx_ansible/edx_ansible/playbooks/edx-east/demo.yml -v -c local -i "127.0.0.1," --extra-vars="COMMON_EDXAPP_SETTINGS=aws"'
fi

if [ "$UPDATE_ASSETS" == 1 ]; then
    # Update LMS Assets
    echo -e "${GREEN}Update LMS Assets"
    docker-compose exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && paver update_assets lms --settings aws'
fi
