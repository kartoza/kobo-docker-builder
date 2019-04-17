export COMPOSE_PROJECT_NAME=kobo-docker
export COMPOSE_FILE=docker-compose.yml:docker-compose.build-images.yml:docker-compose.local-development.yml:docker-compose.volume-definition.yml:docker-compose.volume-overrides.yml:docker-compose.override.yml
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

shell-kpi:
	@docker-compose exec kpi /bin/bash

shell-kobocat:
	@docker-compose exec kobocat /bin/bash

shell-postgres:
	@docker-compose exec postgres /bin/bash

shell-mongo:
	@docker-compose exec mongo /bin/bash

shell-nginx:
	@docker-compose exec nginx /bin/bash

logs-kpi:
	@docker-compose logs -f --tail=30 kpi

logs-kobocat:
	@docker-compose logs -f --tail=30 kobocat

logs-enketo_express:
	@docker-compose logs -f --tail=30 enketo_express

logs-nginx:
	@docker-compose logs -f --tail=30 nginx

backup-media:
	@echo "Backup filename: ${FILENAME}"
	@docker-compose exec kobocat /srv/src/kobocat/docker/backup_media.bash ${FILENAME}

backup-postgres:
	@echo "Backup filename: ${FILENAME}"
	@docker-compose exec postgres /srv/backup_postgres.bash ${FILENAME}

backup-mongo:
	@echo "Backup filename: ${FILENAME}"
	@docker-compose exec mongo /srv/backup_mongo.bash ${FILENAME}

restore-media:
	@echo "Backup filename: ${FILENAME}"
	@docker-compose exec kobocat /srv/src/kobocat/docker/restore_media.bash ${FILENAME}

restore-postgres:
	@echo "Backup filename: ${FILENAME}"
	@docker-compose exec postgres /srv/restore_postgres.bash ${FILENAME}

restore-mongo:
	@echo "Backup filename: ${FILENAME}"
	@docker-compose exec mongo /srv/restore_mongo.bash ${FILENAME}

restart-kpi:
	@docker-compose restart kpi

restart-kobocat:
	@docker-compose restart kobocat

remove-volumes:
	@docker-compose down -v

generate-django-secret:
	@docker-compose run --rm kpi python -c 'from django.utils.crypto import get_random_string; print(get_random_string(50, "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)"))'

generate-self-signed-certificate:
	mkdir -p ./secret
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./secret/ssl.key -out ./secret/ssl.crt

copy-over-certificate:
	docker cp ./secret/. ${COMPOSE_PROJECT_NAME}_nginx_1:/tmp/kobo_toolbox_secrets
