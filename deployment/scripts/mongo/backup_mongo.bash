#!/usr/bin/env bash
set -e

# We are using other backup deduplication so we don't need timestamp on this.
if [ -z "${MONGO_BACKUP_ARCHIVE_FILENAME:-}" ]; then
	timestamp="$(date +%Y.%m.%d.%H_%M)"
	backup_filename="mongo_backup__${timestamp}.mongorestore.tar.gz"
else
	backup_filename="${MONGO_BACKUP_ARCHIVE_FILENAME}"
fi

cd /srv/backups
rm -rf "/srv/backups/${backup_filename}" || true
rm -rf dump
mongodump
tar -czf "${backup_filename}" dump
rm -rf dump

echo "Backup file \`${backup_filename}\` created successfully."
