#!/usr/bin/env bash

echo "Checking Custom theme app settings"

if [ ! -z "$CUSTOM_KOBOCAT_THEME_APP_PIP_URL" ]; then

	echo "Install custom theme: $CUSTOM_KOBOCAT_THEME_APP_PIP_URL"
	if [ ! -z "$CUSTOM_KOBOCAT_THEME_DEPLOY_KEY" ]; then
	    mkdir -p /root/.ssh
        echo "$CUSTOM_KOBOCAT_THEME_DEPLOY_KEY" > /root/.ssh/id_rsa
        chmod -R 600 /root/.ssh/id_rsa
        touch /root/.ssh/known_hosts
        ssh-keyscan github.com >> /root/.ssh/known_hosts
    fi

	pip install --upgrade $CUSTOM_KOBOCAT_THEME_APP_PIP_URL
fi
