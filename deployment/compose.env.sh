#!/usr/bin/env bash
export COMPOSE_PROJECT_NAME=kobo-docker
export COMPOSE_FILE=docker-compose.yml:docker-compose.build-images.yml:docker-compose.local-development.yml:docker-compose.volume-definition.yml:docker-compose.volume-overrides.yml:docker-compose.override.yml
export REPO_NAME=kartoza
export REPO_PREFIX=kobotoolbox
export TAG_NAME=latest
