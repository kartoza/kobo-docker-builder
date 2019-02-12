#!/usr/bin/env bash
set -e

# We are using other backup deduplication so we don't need timestamp on this.
backup_filename="postgres_backup_${KOBO_POSTGRES_DB_NAME}.pg_restore"
rm -rf "/srv/backups/${backup_filename}" || true

su - postgres -c "pg_dump --compress=1 --format=custom ${KOBO_POSTGRES_DB_NAME}" > "/srv/backups/${backup_filename}"
echo "Backup file \`${backup_filename}\` created successfully."
