#!/usr/bin/env bash
set -e

backup_filename=$1

echo "Check current dump folder existence."

if ls dump; then
	echo "Dump folder exists. Try to delete it."
	rm -rf dump
fi

echo "Restore from: ${backup_filename}"

tar -xf ${backup_filename}

mongorestore

rm -rf dump

echo "Restore file ${backup_filename} successfully"
