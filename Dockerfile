FROM maxexcloo/nginx-php:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV ROADIZ_BRANCH master

# Get custom config for xcache
COPY xcache.ini /etc/php5/mods-available/xcache.ini
# Copy nginx virtual host
COPY vhost.conf /data/config/nginx-roadiz.conf

RUN apt-get update -yqq && \
    apt-get install -y \
    curl \
    git \
    php5-curl \
    php5-intl \
    php5-cli \
    php5-dev && \
    cd `mktemp -d` && \
    wget http://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz && \
    tar -xzvf xcache-3.2.0.tar.gz && \
    cd xcache-3.2.0 && \
    phpize --clean && phpize && \
    ./configure --enable-xcache-optimizer --enable-xcache && \
    make && \
    make install && \
    cd /etc/php5/fpm/conf.d/ && \
    ln -s ../../mods-available/xcache.ini 20-xcache.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install Roadiz
RUN mkdir -p /data/http && \
    cd /data/http && \
    git clone -b $ROADIZ_BRANCH https://github.com/roadiz/roadiz.git ./ && \
    composer install -n --no-dev -o && \
    cp conf/config.default.yml conf/config.yml
