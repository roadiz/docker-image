# Roadiz testing Docker image
**Use only for testing purposes**

* Nginx
* Mysql
* PHP5-FPM
* Solr instance (english)

## Before building

Nginx is listening on *server_name* 192.168.59.103 and on *port* 8080 (default Boot2Docker IP on Mac).
But you can change these by entering your own name and port as environment variables:

* `NGINX_SERVER_NAME`
* `NGINX_SERVER_PORT`


```
# Build me
docker build -t roadiz/roadiz ./roadiz

# Run me for the first time on host port 8080 and on boot2docker IP
# Feel free to change these ENV variables to suit your docker setup
docker run -dt -p 8080:80 --env NGINX_SERVER_PORT=8080 --env NGINX_SERVER_NAME=192.168.59.103 roadiz/roadiz

# Enter in container for config (optional)
docker exec -ti <containerID> /bin/bash
```

Then go to http://192.168.59.103:8080 to begin Roadiz setup.

## MySQL

* Host: `localhost`
* User: `root`
* Pass: `root`
* Base: `roadiz`

## Solr

*Solr* is setup with a `roadiz` collection and run internally on port `8983`.
