# Basic docker for renzo testing

* Nginx
* Mysql
* PHP5-FPM

Run on port 8080 --> 80 for IP 192.168.59.103.
Change in `vhost.conf` with your own network configuration.


```
# Build me
docker build -t ambroisemaupate/renzo ./renzo

# Run me
docker run -t -p 8080:80 ambroisemaupate/renzo
```

## MySQL

* User/Pass: `root`
* Base: `renzo`