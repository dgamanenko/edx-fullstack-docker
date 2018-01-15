set -e
set -o pipefail
set -x

docker-compose $DOCKER_COMPOSE_FILES up -d lms
docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && cd /edx/app/edxapp/edx-platform && NO_PYTHON_UNINSTALL=1 paver install_prereqs'

#Installing prereqs crashes the process
docker-compose restart lms

# Run syslog
docker-compose exec lms bash -c '/etc/init.d/rsyslog start && /bin/sleep 10'

# Run edxapp migrations first since they are needed for the service users and OAuth clients
# docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && cd /edx/app/edxapp/edx-platform && NO_PREREQ_INSTALL=1 paver update_db --settings aws'

if [ "$RUN_MIGRATINS" == 1 ]; then
    # Run edxapp lms migrations
    echo -e "${GREEN}Run edxapp lms migrations"
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py lms migrate --settings=aws'
fi

if [ "$DB_PROVISION" == 1 ]; then
    # Create a superuser for edxapp
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws manage_user staff staff@example.com --superuser --staff'
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username=\"staff\"); user.set_password(\"edx\"); user.save()" | python /edx/app/edxapp/edx-platform/manage.py lms shell  --settings=aws'

    #Create honor user for edxapp
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws manage_user honor honor@example.com'
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username=\"honor\"); user.set_password(\"edx\"); user.save()" | python /edx/app/edxapp/edx-platform/manage.py lms shell  --settings=aws'

    #Create verified user for edxapp
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws manage_user verified verified@example.com'
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username=\"verified\"); user.set_password(\"edx\"); user.save()" | python /edx/app/edxapp/edx-platform/manage.py lms shell  --settings=aws'

    #Create audit user for edxapp
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws manage_user audit audit@example.com'
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username=\"audit\"); user.set_password(\"edx\"); user.save()" | python /edx/app/edxapp/edx-platform/manage.py lms shell  --settings=aws'


    docker-compose exec lms bash -c 'cd /var/tmp && git clone https://github.com/edx/edx-demo-course.git && cd /edx/app/edxapp/edx-platform && source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py cms --settings=aws import /edx/var/edxapp/data  /var/tmp/edx-demo-course'

    # Enable the LMS-E-Commerce integration
    echo -e "${GREEN}Enable the LMS-E-Commerce integration"
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws configure_commerce'

#     # Create demo course and users
#     echo -e "${GREEN}Create demo course and users"
#     docker-compose exec lms bash -c '/edx/app/edx_ansible/venvs/edx_ansible/bin/ansible-playbook /edx/app/edx_ansible/edx_ansible/playbooks/edx-east/demo.yml -v -c local -i "127.0.0.1," --extra-vars="COMMON_EDXAPP_SETTINGS=aws"'
fi

if [ "$UPDATE_ASSETS" == 1 ]; then
    # Update LMS Assets
    echo -e "${GREEN}Update LMS Assets"
    docker-compose exec lms bash -c 'source /edx/app/edxapp/venvs/edxapp/bin/activate && cd /edx/app/edxapp/edx-platform && paver update_assets lms --settings aws'
fi
