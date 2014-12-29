#!/bin/sh

# Replace nginx virtual host param against ENV vars at each startup

sed -i "s/server_name <SERVER_PLACEHOLDER>/server_name ${NGINX_SERVER_NAME}/g" /etc/nginx/sites-available/default;
sed -i "s/fastcgi_param SERVER_PORT <SERVER_PORT_PLACEHOLDER>/fastcgi_param SERVER_PORT ${NGINX_SERVER_PORT}/" /etc/nginx/sites-available/default;