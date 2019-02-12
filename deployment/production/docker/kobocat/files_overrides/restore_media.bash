#!/usr/bin/env bash
set -e
source /etc/profile

backup_filename=$1
KOBOCAT_MEDIA_URL="${KOBOCAT_MEDIA_URL:-media}"

echo "Designated MEDIA url: ${KOBOCAT_MEDIA_URL}"

echo "Kobocat SRC dir: ${KOBOCAT_SRC_DIR}"

KOBOCAT_MEDIA_DIR="${KOBOCAT_SRC_DIR}/${KOBOCAT_MEDIA_URL}"

echo "Kobocat MEDIA dir: ${KOBOCAT_MEDIA_DIR}"

echo "Check current media folder existence."

if ls ${KOBOCAT_MEDIA_DIR}; then
	echo "Media folder exists. Try to delete it."
	if ! rm -rf ${KOBOCAT_MEDIA_DIR}; then
		echo "Failed to delete. Probably because media folder is a mounted volume."
		echo "Attempt to delete subdir."

		rm -rf ${KOBOCAT_MEDIA_DIR}/*

		echo "Successfully delete subdir."
	fi
fi

if ! ls ${KOBOCAT_MEDIA_DIR}; then
	echo "Creating new media folder."
	mkdir -p ${KOBOCAT_MEDIA_DIR}
fi

echo "Restore from: ${backup_filename}"

tar -xf ${backup_filename} --strip-components=1 -C ${KOBOCAT_MEDIA_DIR}

echo "Restore file ${backup_filename} successfully"
