# Roadiz test docker image
**Use only for testing purposes**

* Nginx
* Mysql
* PHP5-FPM
* Solr instance (english)

## Before building

Nginx is listening on ip 192.168.59.103 (default Boot2Docker IP on Mac).
Change it in `vhost.conf` file to suit your own network configuration before *building* your own image.

```
# Build me
docker build -t roadiz/roadiz ./roadiz

# Run me for the first time on host port 8080
docker run -d -p 8080:80 roadiz/roadiz

# Enter in container for config
docker exec -ti <containerID> /bin/bash
```

## MySQL

* Host: `localhost`
* User: `root`
* Pass: `root`
* Base: `roadiz`

## Solr

*Solr* is setup with a `roadiz` collection and run internally on port `8983`.
