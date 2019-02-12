#!/usr/bin/env bash
set -e

backup_filename=$1

echo "Check current database existence."

if su - postgres -c "psql -l -d ${KOBO_POSTGRES_DB_NAME}"; then

	echo "Delete current database: ${KOBO_POSTGRES_DB_NAME}"
	su - postgres -c "dropdb ${KOBO_POSTGRES_DB_NAME}"

fi

echo "Create new database: ${KOBO_POSTGRES_DB_NAME}"
su - postgres -c "createdb ${KOBO_POSTGRES_DB_NAME}"

echo "Restore from ${backup_filename}"

su - postgres -c "pg_restore -d ${KOBO_POSTGRES_DB_NAME} ${backup_filename}"
