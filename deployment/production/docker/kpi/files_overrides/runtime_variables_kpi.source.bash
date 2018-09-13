# Override if this settings present
if [[ ! -z "${USE_ENV_VAR}" ]]; then
    # Directly uses environment variable
    export ENKETO_URL="${ENKETO_URL}"
    export KOBOCAT_URL="${KOBOCAT_URL}"
    export KOBOCAT_INTERNAL_URL="${KOBOCAT_INTERNAL_URL}"
    export CSRF_COOKIE_DOMAIN="${CSRF_COOKIE_DOMAIN}"
    export DJANGO_ALLOWED_HOSTS="${DJANGO_ALLOWED_HOSTS}"
elif [[ ! -z "${PUBLIC_DOMAIN_NAME}" ]]; then
    export ENKETO_URL="https://${ENKETO_EXPRESS_PUBLIC_SUBDOMAIN}.${PUBLIC_DOMAIN_NAME}"
    export KOBOCAT_URL="https://${KOBOCAT_PUBLIC_SUBDOMAIN}.${PUBLIC_DOMAIN_NAME}"
    export KOBOCAT_INTERNAL_URL="${KOBOCAT_URL}" # FIXME: Use an actual internal URL.
    export CSRF_COOKIE_DOMAIN=".${PUBLIC_DOMAIN_NAME}"
    export DJANGO_ALLOWED_HOSTS=".${PUBLIC_DOMAIN_NAME}"

elif [[ ! -z "${HOST_ADDRESS}" ]]; then
    # Local configuration
    export ENKETO_URL="http://${HOST_ADDRESS}:${ENKETO_EXPRESS_PUBLIC_PORT}"
    export KOBOCAT_URL="http://${HOST_ADDRESS}:${KOBOCAT_PUBLIC_PORT}"
    export KOBOCAT_INTERNAL_URL="${KOBOCAT_URL}" # FIXME: Use an actual internal URL.
    export CSRF_COOKIE_DOMAIN="${HOST_ADDRESS}"
    export DJANGO_ALLOWED_HOSTS="${HOST_ADDRESS}"
else
    echo 'Please fill out your `envfile`!'
    exit 1
fi

export DJANGO_DEBUG="${KPI_DJANGO_DEBUG}"
export RAVEN_DSN="${KPI_RAVEN_DSN}"
