# Quick and dirty docker for Roadiz
**Use only for testing purposes**

* Nginx
* Mysql
* PHP5-FPM
* Solr instance (english)

Run on port 8080 --> 80
On IP 192.168.59.103. Change in `vhost.conf` with your own network configuration
before *building* your own image.


```
# Build me
docker build -t roadiz/roadiz ./roadiz

# Run me for the first time
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
