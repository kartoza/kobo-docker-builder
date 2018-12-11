#!/usr/bin/env bash

echo "Checking Custom theme app settings"

if [ ! -z "CUSTOM_KOBOCAT_THEME_APP_PIP_URL" ]; then

	echo "Install custom theme: CUSTOM_KOBOCAT_THEME_APP_PIP_URL"

	git clone --branch ${KOBOCAT_TEMPLATE_TAG} --depth 1 ${CUSTOM_KOBOCAT_THEME_APP_PIP_URL} custom_kobocat_theme
fi
