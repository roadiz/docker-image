# Quick and dirty docker for Renzo
**Use only for testing purposes**

* Nginx
* Mysql
* PHP5-FPM

Run on port 8080 --> 80
On IP 192.168.59.103. Change in `vhost.conf` with your own network configuration
before *building* your own image.


```
# Build me
docker build -t ambroisemaupate/renzo ./renzo

# Run me
docker run -t -p 8080:80 ambroisemaupate/renzo
```

## MySQL

* Host: `localhost`
* User: `root`
* Pass: `root`
* Base: `renzo`