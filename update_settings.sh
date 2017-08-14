#!/bin/bash

LMS_URL=edx-docker-fullstack.raccoongang.com
CMS_URL=studio-docker-fullstack.raccoongang.com
PREVIEW_URL=preview-docker-fullstack.raccoongang.com

EMAIL_HOST_USER='username'
EMAIL_HOST_PASSWORD='password'
EMAIL_HOST: "email-smtp.eu-west-1.amazonaws.com"
EMAIL_PORT: 587
EMAIL_USE_TLS: true

find -type f -name '*.json' | xargs sed -i 's/edx.fullstack.nginx:18000/'$LMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/http:\/\/'$LMS_URL'/https:\/\/'$LMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/edx.fullstack.nginx:18010/'$CMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/http:\/\/'$CMS_URL'/https:\/\/'$CMS_URL'/g'
find -type f -name '*.json' | xargs sed -i 's/edx.fullstack.preview/'$PREVIEW_URL'/g'

EMAIL_HOST_USER=$(echo ${EMAIL_HOST_USER} | sed 's:/:\\\/:g')
EMAIL_HOST_PASSWORD=$(echo ${EMAIL_HOST_PASSWORD} | sed 's:/:\\\/:g')
find -type f -name '*.json' | xargs sed -i 's/"EMAIL_HOST_PASSWORD": "",/"EMAIL_HOST_PASSWORD": "'$EMAIL_HOST_PASSWORD'",/g'
find -type f -name '*.json' | xargs sed -i 's/"EMAIL_HOST_USER": "",/"EMAIL_HOST_USER": "'$EMAIL_HOST_USER'",/g'
find -type f -name '*.json' | xargs sed -i 's/"EMAIL_HOST": "email-smtp.eu-west-1.amazonaws.com",/"EMAIL_HOST": "'$EMAIL_HOST'",/g'
find -type f -name '*.json' | xargs sed -i 's/"EMAIL_PORT": 587,/"EMAIL_PORT": "'$EMAIL_PORT'",/g'

