#!/bin/bash

cp /tmp/cms.conf /etc/nginx/conf.d/cms.conf
cp /tmp/lms.conf /etc/nginx/conf.d/lms.conf
cp /tmp/forum.conf /etc/nginx/conf.d/forum.conf
cp /tmp/programs.conf /etc/nginx/conf.d/programs.conf
cp /tmp/credentials.conf /etc/nginx/conf.d/credentials.conf

sed -i -- "s/NGINX_CMS_SERVER_NAME/${NGINX_CMS_SERVER_NAME}/g" /etc/nginx/conf.d/cms.conf
sed -i -- "s/NGINX_LMS_PORT/${NGINX_LMS_PORT}/g" /etc/nginx/conf.d/lms.conf
sed -i -- "s/NGINX_LMS_SERVER_NAME/${NGINX_LMS_SERVER_NAME}/g" /etc/nginx/conf.d/lms.conf
sed -i -- "s/NGINX_PREVIEW_SERVER_NAME/${NGINX_PREVIEW_SERVER_NAME}/g" /etc/nginx/conf.d/lms.conf

rm -rf /etc/nginx/conf.d/default.conf

/usr/sbin/nginx -g 'daemon off;'
