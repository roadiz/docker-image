# Roadiz docker-image

**Based on https://github.com/maxexcloo/Docker — maxexcloo/nginx-php**

This image will install:

* Git
* Composer
* curl
* php5-cli
* php5-curl
* php5-dev (needed to compile XCache)
* php5-xcache - from its sources as *maxexcloo/nginx-php* uses PHP 5.6.

## Environment variables

* `ROADIZ_BRANCH` *master* or *develop*

## Docker dependencies

Roadiz image will work with:

* A *maxexcloo/data* container for volume handling:

```bash
docker run -t --name="my-roadiz-data" maxexcloo/data
```

* A *maxexcloo/mariadb* container for its database:

```bash
docker run -t --name="my-roadiz-mariadb" \
           --env="MARIADB_USER=foo" --env="MARIADB_PASS=bar" \
           --env="MARIADB_DB=foo" maxexcloo/mariadb
```

## Building Roadiz image

```bash
# Build roadiz image
docker build -t roadiz/roadiz ./path/to/roadiz-image
# Launch me
docker run -t --name="my-roadiz" -p 80:80 && \
              --env ROADIZ_BRANCH=master \
              --volumes-from="my-roadiz-data" && \
              --link="my-roadiz-mariadb:mariadb" roadiz/roadiz
```

Your database credentials will be:

* Host: `mariadb`
* User: `foo`
* Password: `bar`
* Database: `foo`

## Using Roadiz CLI commands

You can of-course use Roadiz `bin/roadiz` commands to manage your website
parameters and cache in CLI. But before doing anything, pay attention to
do it as the `core` user, **NOT** the `root` user.

```bash
# Switch to core user
su core

cd /data/http
# For example clear Roadiz app cache
bin/roadiz cache --clear-all
```

## Using a deploy/access key for Github/Gitlab

This docker image is configured to look for your *SSH* public key in `/data/secure/ssh`.
Pay attention to generate you *ssh-key* as `core` user: `su -s /bin/bash core`
before doing anything in your `/data` folder.

```bash
# Switch to core user
su core

# Generate public/private keys
ssh-keygen -t rsa -b 2048 -N '' -f /data/secure/ssh/id_rsa \
           -C "Deploy key ($HOSTNAME) for private repository"
# Add the generated /data/secure/ssh/id_rsa.pub key to your Github/Gitlab account

# Clone your custom theme
cd /data/http/themes
git clone git@github.com:private-account/custom-theme.git CustomTheme
# Install your theme composer dependencies (if any)
cd /data/http
composer update --no-dev -o
```

Be careful, this image use *XCache* OPcache and Var cache. If you change your PHP
sources, you’ll need to restart your container as `xcache.stat` is set to `Off`.
If this bother you, change this value to `On` in `/etc/php5/mods-available/xcache.ini`.
