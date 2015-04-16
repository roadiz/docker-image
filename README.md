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
           --env="MARIADB_USER=foo" --env="MARIADB_PASSWORD=bar" \
           --env="MARIADB_DATABASE=foo" maxexcloo/mariadb
```

* Then you can create your roadiz image:

```
# Build roadiz image
docker build -t roadiz/roadiz ./path/to/roadiz-image
# Launch me
docker run -t --name="my-roadiz" -p 80:80 --env ROADIZ_BRANCH=master \
           --volumes-from="my-roadiz-data" --link="roadiz1-mariadb:mariadb" roadiz/roadiz
```
