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
grade image AND push latest tag to docker hub.

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
