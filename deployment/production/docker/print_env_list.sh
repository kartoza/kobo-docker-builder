#!/usr/bin/env bash

cur_dir=$PWD
deployment_dir=$PWD/../../
kobo_docker_dir=$deployment_dir/../src/kobo-docker
envfiles_dir=$kobo_docker_dir/envfiles

env_lists=("$kobo_docker_dir/envfile.local.txt" "$kobo_docker_dir/envfile.server.txt" "$envfiles_dir/aws.txt" "$envfiles_dir/external_services.txt" "$envfiles_dir/kobocat.txt" "$envfiles_dir/kpi.txt" "$envfiles_dir/nginx.txt" "$envfiles_dir/smtp.txt")

for env_print in "${env_lists[@]}"
do
	echo "# $env_print"
	python -c "from utils.helpers import *;print_env_list('$env_print')"
done
