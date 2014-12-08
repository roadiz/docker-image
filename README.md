# Quick and dirty docker for Roadiz
**Use only for testing purposes**

* Nginx
* Mysql
* PHP5-FPM

Run on port 8080 --> 80
On IP 192.168.59.103. Change in `vhost.conf` with your own network configuration
before *building* your own image.


```
# Build me
docker build -t ambroisemaupate/roadiz ./roadiz

# Run me for the first time
docker run -t -p 8080:80 ambroisemaupate/roadiz
```

## MySQL

* Host: `localhost`
* User: `root`
* Pass: `root`
* Base: `roadiz`