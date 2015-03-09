FROM debian:wheezy
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_SERVER_PORT 8080
ENV NGINX_SERVER_NAME 192.168.59.103


RUN apt-get update -yqq && \
    apt-get install -y wget

# Get DotDeb latest packages for latest version
RUN echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list && \
    echo "deb-src http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list && \
    echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list && \
    echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list && \
    wget http://www.dotdeb.org/dotdeb.gpg && \
    apt-key add dotdeb.gpg


# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
RUN echo "mysql-server-5.6 mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server-5.6 mysql-server/root_password_again password root" | debconf-set-selections

RUN apt-get update -yqq && \
    apt-get install -y \
    curl \
    git \
    mysql-server \
    nginx \
    openjdk-7-jre-headless \
    php5-cli \
    php5-fpm \
    php5-xcache \
    php5-gd \
    php5-mysql \
    php5-imap \
    php5-curl \
    php5-intl \
    supervisor \
    zip \
    && \
    apt-get install -y logrotate

# Copy nginx virtual host
COPY vhost.conf /etc/nginx/sites-enabled/default

# Prepare private key for downloading Roadiz
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

# Modify config file to undaemonize nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Modify config file to undaemonize php-fpm
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf

# ----------- Install Solr --------------

RUN curl http://mir2.ovh.net/ftp.apache.org/dist/lucene/solr/4.10.2/solr-4.10.2.tgz | tar xz && \
    mv solr-4.10.2 /var/solr

COPY solrCollection /var/solr/example/solr/roadiz

# ----------- Install Roadiz ------------

# We need mysql started to create empty database
RUN service mysql start && \
    mysql -u root -proot -e "CREATE DATABASE roadiz;"


#### Install Roadiz
WORKDIR /roadiz
RUN git clone https://github.com/roadiz/roadiz.git ./ && \
    composer install --n --no-dev

# Copy default conf for Roadiz
COPY config.yml /roadiz/conf/config.yml

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD init.sh /init.sh

RUN chown -R www-data:www-data /roadiz && \
    chmod +x /init.sh

VOLUME ["/roadiz"]

EXPOSE 80

CMD ["/usr/bin/supervisord"]
