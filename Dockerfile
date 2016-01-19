FROM maxexcloo/nginx-php:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

ENV ROADIZ_BRANCH master

# Get custom config for xcache
COPY xcache.ini /etc/php5/mods-available/xcache.ini

RUN apt-get update -yqq && \
    apt-get install -y \
    curl \
    git \
    cron \
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
    rm /etc/nginx/conf.d/02cache.conf && \
    php5dismod -s ALL opcache && \
    php5enmod -s ALL xcache && \
    sed -i'.original' 's/\;date.timezone \=/date.timezone = Europe\/Paris/' /etc/php5/cli/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    mkdir -p /data/http

ADD config /config
ADD etc /etc
