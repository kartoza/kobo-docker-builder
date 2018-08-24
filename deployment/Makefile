export COMPOSE_PROJECT_NAME=kobo-docker
export COMPOSE_FILE=docker-compose.yml:docker-compose.build-images.yml:docker-compose.local-development.yml:docker-compose.volume-definition.yml:docker-compose.override.yml
export REPO_NAME=kartoza
export REPO_PREFIX=kobotoolbox
export TAG_NAME=latest

SHELL := /bin/bash

up: build
	@docker-compose up -d --remove-orphans ${ARGS}

down:
	@docker-compose down

build:
	@docker-compose build

pull:
	@docker-compose pull

status:
	@docker-compose ps

logs-kpi:
	@docker-compose logs -f --tail=30 kpi

logs-kobocat:
	@docker-compose logs -f --tail=30 kobocat

logs-enketo_express:
	@docker-compose logs -f --tail=30 enketo_express

logs-nginx:
	@docker-compose logs -f --tail=30 nginx

remove-volumes:
	@docker-compose down -v

generate-django-secret:
	@docker-compose run --rm kpi python -c 'from django.utils.crypto import get_random_string; print(get_random_string(50, "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)"))'

generate-self-signed-certificate:
	mkdir -p ./secret
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./secret/ssl.key -out ./secret/ssl.crt

copy-over-certificate:
	docker cp ./secret/. ${COMPOSE_PROJECT_NAME}_nginx_1:/tmp/kobo_toolbox_secrets
