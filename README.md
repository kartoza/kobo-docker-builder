# Kobo toolbox builder

This repo is used build and push modified images of kobotoolbox development version.
It was modified so it can be deployed to rancher (a complete image).


# How to build

After cloning this project, init the submodules.

```
git submodule init
git submodule update
```

Then all the scripts were stored in `deployment` dir. Change directory to that dir.

In deployment there will be a docker-compose.yml. This is the base compose file.
Create your own docker-compose override file by copy-pasting and modifying `docker-compose.local-development.yml`.
If you didn't change anything just use this content:

```
version: '2'
```


Next, we need a self signed certificate if you want to use https mode setup.
Assumming you already have openssl installed, generate the certificate and follow openssl instructions.

```
make generate-self-signed-certificate
```

You need to copy the default settings:

```
cp ../src/kobo-docker/envfile.server.txt ./envfile.server.txt
```

You can change options in that default settings.

Next you need to build the base image

```
make build
```

Then you can start up the instance

```
make up
```

To shut it down, do

```
make down
```

To shut it down AND removing the volumes, do

```
make remove-volumes
```


There are also some helpers method for you like:

```
make status
make logs-kpi
make logs-kobocat
make logs-nginx
make logs-enketo_express
```

If you are using https mode setup, copy the certificate to nginx containers.

```
make up
make copy-over-certificate:
```

# Build production images

You need to generate the base image first using `make build`.

Go to `deployment/production/docker` we will use this as our working dir.

You need to specify some settings. Use default values from env_list.sample.env

```
cp env_list.sample.env env_list.env
```

Make sure you know what you're doing because this will build production
grade image AND push latest tag to docker hub. Instructions below are just quick examples.
For further info, look on [Production Build README](deployment/production/docker/README.md)

```
docker login
./build_all.sh
```

To build individual image go inside image directory. This is an example:

```
cd kpi
```

You can specify the tag of the image you want to build (optional):

```
export TAG_NAME=2.018.32
```

You can specify the docker build args

```
export BUILD_ARGS="--pull --no-cache"
```

Then you build the image (it will also push into the expected tag)

```
./build.sh
```

# Production notes

## Setting up HTTPS

To set up https out of the box using this docker images, you should copy over
your certified `ssl.crt` and `ssl.key` into `deployment/secret` directory.

Then you have to configure your `docker-compose.override.yml` to use https settings.
This is some example taken from Kobotoolbox server.yml

```
# For public, HTTPS servers.
version: '2'
services:
  kobocat:
    environment:
      - ENKETO_PROTOCOL=https
   
  kpi:
	environment:
	  - SECURE_PROXY_SSL_HEADER=HTTP_X_FORWARDED_PROTO, https

  nginx:
    environment:
      - NGINX_CONFIG_FILE_NAME=nginx_site_https_subdomain.conf
      - TEMPLATED_VAR_REFS=$${PUBLIC_DOMAIN_NAME} $${KOBOFORM_PUBLIC_SUBDOMAIN} $${KOBOCAT_PUBLIC_SUBDOMAIN} $${ENKETO_EXPRESS_PUBLIC_SUBDOMAIN}
```

Modify `deployment/envfile.server.txt` accordingly for https setup


## Setting up HTTPS behind Haproxy LB SSL termination

There are some cases where you put your Kobotoolbox instance behind LB and let 
Haproxy LB terminate the SSL/HTTPS. For example if you're deploying through Rancher,
it is quite useful to manage the certificate from Rancher UI and let LB handle
SSL termination.

Behind LB, you need to setup your Kobotoolbox stack using http protocol, but you
should allow your LB to forward the protocol scheme (so Kobo knows that client
is actually using HTTPS).

This is some typical extra Haproxy config:

```
# Redirect port 80 traffic without ssl to use https protocol (to 443)
frontend 80
redirect scheme https code 301 if !{ ssl_fc }

# Allow haproxy to pass https protocol X-Forwarded-Proto header
# this will let kobotoolbox to send all URL based redirect to this protocol
frontend 443
reqadd X-Forwarded-Proto:\ https
```

To test that this actual configuration works. You need to check using curl. 

From your local computer, send request over to your public Kobo instance (http)

```
curl --verbose http://<kobo public dns>
```

You should have a redirected result like this (to https):

```
* Rebuilt URL to: http://<kobo public dns>/
*   Trying <some IP address>...
* TCP_NODELAY set
* Connected to <kobo public dns> (<some IP address>) port 80 (#0)
> GET / HTTP/1.1
> Host: <kobo public dns>
> User-Agent: curl/7.58.0
> Accept: */*
> 
< HTTP/1.1 301 Moved Permanently
< Content-length: 0
< Location: https://<kobo public dns>/
< Connection: Keep-Alive
< Age: 0
< Date: Thu, 18 Oct 2018 16:31:04 GMT
< 
* Connection #0 to host <kobo public dns> left intact
```

Then you should check that your https connection does received.

```
curl --verbose https://<kobo public dns>
```

```
* Rebuilt URL to: https://<kobo public dns>/
*   Trying <some IP address>...
* TCP_NODELAY set
* Connected to <kobo public dns> (<some IP address>) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
* ALPN, server did not agree to a protocol
* Server certificate:
*  subject: CN=<kobo public dns>
*  start date: Sep 17 05:00:33 2018 GMT
*  expire date: Dec 16 05:00:33 2018 GMT
*  subjectAltName: host "<kobo public dns>" matched cert's "<kobo public dns>"
*  issuer: C=US; O=Let's Encrypt; CN=Let's Encrypt Authority X3
*  SSL certificate verify ok.
> GET / HTTP/1.1
> Host: <kobo public dns>
> User-Agent: curl/7.58.0
> Accept: */*
> 
< HTTP/1.1 302 FOUND
< Server: nginx/1.10.3 (Ubuntu)
< Date: Thu, 18 Oct 2018 16:34:37 GMT
< Content-Type: text/html; charset=utf-8
< Transfer-Encoding: chunked
< Vary: Accept-Language, Cookie
< Location: https://<kobo public dns>/accounts/login/?next=/kobocat/
< Content-Language: en
< 
* Connection #0 to host <kobo public dns> left intact
```

In the above sample, note that your request is being redirected to a https url 
for login page: `https://<kobo public dns>/accounts/login/?next=/kobocat/`.
This means your LB successfully terminate your SSL connection and send your request 
to your Kobotoolbox instance backend using http, but with X-Forwarded-Proto header 
set to https, so the result returned using https protocol. If this wasn't set 
properly, your Kobo instance will return http URL because it doesn't know the 
request came from a proxy.

This setup is needed in general because Koboform communicate via Ajax request, 
so it needs to communicate in the same protocol (web client request AJAX using https)
