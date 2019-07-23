# Requirements

The build script uses Python script (Python 2.7). Make sure you are able to execute Python, and the following requirements are installed.

```
pip install -r requirements.txt
```

# How to build

Create an environment file (bash syntax) that describes your build environment.
Typically like this (default one is stored as `build.sample.env`):

```
#!/usr/bin/env bash

export REPO_NAME=kartoza
export REPO_PREFIX=kobotoolbox
```

The image built will correspond to this environment variable. If you build `mongo` image, then the image tag will be:
`kartoza/kobotoolbox_mongo:latest`
For this example, we named the file as ```build.env```

To build all related images with the default settings (target repo and service name defined in each script folders), execute:

```
source build.env
./build_all.sh
```

If you want to build each individual images, go into the image subfolders and run `build.sh` script (after sourcing `build.env`).
Let's say you want to build `mongo` image

```
source build.env
cd mongo
./build.sh
```

If you already log in to your docker hub credentials, it will push the image to docker hub.

# Image that needs private repo

Image such as `kobocat` contains custom template skin repo, which is currently private repo.
In order for git client to be able to fetch this repo, you need to generate SSH deploy keys.
Upload the public keys to the private repo, then store the private key in `kobocat/ssh_key` 
directory. Name the private key, `id_rsa`

