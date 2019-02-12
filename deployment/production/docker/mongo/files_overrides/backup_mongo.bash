#!/usr/bin/env bash
set -e

# We are using other backup deduplication so we don't need timestamp on this.
backup_filename="mongo_backup.mongorestore.tar.gz"

cd /srv/backups
rm -rf "/srv/backups/${backup_filename}" || true
rm -rf dump
mongodump
tar -czf "${backup_filename}" dump
rm -rf dump

echo "Backup file \`${backup_filename}\` created successfully."
