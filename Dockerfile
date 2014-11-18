FROM debian:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install -y wget

# Get DotDeb latest packages for latest version
RUN echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list
RUN echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
RUN wget http://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg

RUN apt-get update

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
RUN echo "mysql-server-5.6 mysql-server/root_password password root" | sudo debconf-set-selections
RUN echo "mysql-server-5.6 mysql-server/root_password_again password root" | sudo debconf-set-selections

RUN apt-get install -y nginx zip git curl nano php5-cli php5-fpm mysql-server
RUN apt-get install -y php5-xcache php5-gd php5-mysql php5-imap php5-curl php5-imagick php5-intl

RUN mysql_secure_installation

# Copy nginx virtual host
COPY vhost.conf /etc/nginx/sites-enabled/default

# Prepare private key for downloading Renzo
RUN mkdir -p ~/.ssh
COPY id_rsa.dockerRenzoTest ~/.ssh/id_rsa
RUN chmod -R 0700 ~/.ssh

# Create web root
RUN mkdir -p /renzo
RUN chown -R www-data:www-data /renzo

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Edit some php-fpm configs
RUN sed -e 's/;cgi.fix_pathinfo = 0/cgi.fix_pathinfo = 0/' -i /etc/php5/fpm/php.ini
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf
RUN sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Copy startup script
COPY init.sh /init.sh
RUN chmod +x /init.sh


#### Install Renzo
WORKDIR /renzo
RUN git clone -b develop git@gitlab.rezo-zero.com:rezo-zero-open-source/renzo.git ./
RUN cp conf/config.default.json conf/config.json
RUN composer install

RUN mysql -u root -proot -e "CREATE DATABASE renzo;"

EXPOSE 80

CMD ["/init.sh"]