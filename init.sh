#!/bin/bash

logrotate /etc/logrotate.d/*

service mysql start;
service php5-fpm start;
service nginx start;

/bin/bash;