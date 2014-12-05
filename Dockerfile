FROM debian:wheezy
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yqq
RUN apt-get install -y wget

# Get DotDeb latest packages for latest version
RUN echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list && \
    echo "deb-src http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list && \
    echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list && \
    echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    wget http://www.dotdeb.org/dotdeb.gpg && \
    apt-key add dotdeb.gpg && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

RUN apt-get update -yqq

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
RUN echo "mysql-server-5.6 mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server-5.6 mysql-server/root_password_again password root" | debconf-set-selections && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN apt-get install -y oracle-java8-installer solr-tomcat nginx zip git curl nano php5-cli php5-fpm mysql-server \
    php5-xcache php5-gd php5-mysql php5-imap php5-curl php5-imagick php5-intl && \
    apt-get install -y logrotate

# Copy nginx virtual host
COPY vhost.conf /etc/nginx/sites-enabled/default

# Prepare private key for downloading Renzo
RUN mkdir -p /root/.ssh && \
    chmod -R 0700 /root/.ssh && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# Create web root
RUN mkdir -p /roadiz

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Edit some php-fpm configs
RUN sed -e 's/;cgi.fix_pathinfo = 0/cgi.fix_pathinfo = 0/' -i /etc/php5/fpm/php.ini && \
    sed -e 's/post_max_size = 8M/post_max_size = 128M/' -i /etc/php5/fpm/php.ini && \
    sed -e 's/upload_max_filesize = 2M/upload_max_filesize = 128M/' -i /etc/php5/fpm/php.ini && \
    sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf && \
    sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf

# Get custom config for xcache
COPY xcache.ini /etc/php5/mods-available/xcache.ini

# We need mysql started to create empty database
RUN service mysql start && \
    mysql -u root -proot -e "CREATE DATABASE roadiz;"

# Copy startup script
COPY init.sh /init.sh
RUN chmod +x /init.sh

#### Install Renzo
WORKDIR /roadiz
RUN git clone https://github.com/roadiz/roadiz.git ./
RUN composer install

# Copy default conf for Roadiz
COPY config.json conf/config.json

RUN chown -R www-data:www-data /roadiz

EXPOSE 80

CMD ["/init.sh"]
