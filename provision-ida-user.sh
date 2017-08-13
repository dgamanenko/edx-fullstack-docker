
#This script depends on the LMS being up!

name=$1
port=$2

echo -e "${GREEN}Creating service user and OAuth client for ${name}...${NC}"
docker exec -t edx.fullstack.lms  bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws manage_user $1_worker $1_worker@example.com --staff --superuser' -- "$name"
docker exec -t edx.fullstack.lms  bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws create_oauth2_client "http://edx.fullstack.nginx:$2" "http://edx.fullstack.nginx:$2/complete/edx-oidc/" confidential --client_name $1 --client_id "secure-$1-client" --client_secret "secure-$1-secret" --trusted --logout_uri "http://edx.fullstack.nginx:$2/logout/" --username $1_worker' -- "$name" "$port"
# docker exec -t edx.fullstack.lms  bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=aws create_oauth2_client "http://edx.fullstack.$1:$2" "http://edx.fullstack.$1:$2/complete/edx-oidc/" confidential --client_name $1 --client_id "secure-$1-client" --client_secret "secure-$1-secret" --trusted --logout_uri "http://edx.fullstack.$1:$2/logout/" --username $1_worker' -- "$name" "$port"