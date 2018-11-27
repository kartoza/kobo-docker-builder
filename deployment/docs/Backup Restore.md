# Kobotoolbox Internal Backup Restore

Vanilla Kobotoolbox image provides scheduled backup service.
This document here describe how this backup works, what to backups, and how 
to restore and manage them. 

There are 3 services with backup service: `kobocat`, `postgres`, and `mongo`

## Scheduled Backup

Kobo provides scheduled backup built in. These backup service were executed 
by a cronjob. There are several environment variables that needs to be set up
in order for this cronjob to be setup by docker entrypoint script.

The environment variable have suffix: `_BACKUP_SCHEDULE`. These are:

`KOBOCAT_MEDIA_BACKUP_SCHEDULE`
`POSTGRES_BACKUP_SCHEDULE`
`MONGO_BACKUP_SCHEDULE`

Each of this environment can be set with a value of cron schedule.
For example:

`0 1 * * 0` means every 01:00 AM UTC on Sunday

Set these environment variables in each service that needs them. For example, 
to schedule postgres backup, then you need to set `POSTGRES_BACKUP_SCHEDULE` 
value in `postgres` service (docker-compose.yml file).

## Manual Backup trigger

You can also trigger the backup manually by executing the bash script (that is 
actually executed by cron schedule) manually.

First, you need to go inside the service which provides the backup.
Then run the backup script.

For each service, the backup script location is defined here:

- kobocat: `/srv/src/kobocat/docker/backup_media.bash`
- postgres: `/srv/backup_postgres.bash`
- mongo: `/srv/backup_mongo.bash`

For example, if you want to backup postgres, then go inside postgres service shell.
Then execute: `/srv/backup_postgres.bash` in shell.

For local development, we provide Make command helpers to do these, respectively:

- kobocat: `make backup-media`
- postgres: `make backup-postgres`
- mongo: `make backup-mongo`

## Manual Backup restore

If you have the backup file, you can simply run restore script by executing 
the restore script pair. Just change the `backup_` script prefix with `restore_`

For example, if you want to restore postgres, then go inside postgres service shell.
Then execute: `/srv/restore_postgres.bash <backup_filename>` in shell. 
Note that every restore command need an argument of backup file path (`<backup_filename>`).

Additional important note: In order to restore a backup, of course the current data will be destroyed.
So, make sure that doing a restore is a conscious decision and the backup file 
was validated first.

For local development, we provide Make command helpers in parity with the backup command,
respectively:

- kobocat: `make restore-media`
- postgres: `make restore-postgres`
- mongo: `make restore-mongo`

A restore command will need you to specify `FILENAME` argument.
This `FILENAME` argument is the file path (from containers perspective) 
to the location of backup file.

All backup files will be managed inside `/srv/backups` directory in each service.

So, for example if you have a filename called `postgres_backup_kobotoolbox__2018.11.27.10_30.pg_restore`, 
by default file location, if you want to restore this file, you do:

`make restore-postgres FILENAME=/srv/backups/postgres_backup_kobotoolbox__2018.11.27.10_30.pg_restore`

## Backup file management and rotation policy

Vanilla kobotoolbox docker image **does not** have backup rotation policy.
In other words, if you schedule a weekly/daily backup, it will eventually pile up.

To do this, you should cascade these backup script with another backup rotation file management.
Each backup file will have standardized file format such as:

- kobocat: `kobocat_media__{timestamp}.tar`
- mongo: `mongo_backup__{timestamp}.mongorestore.tar.gz`
- postgres: `postgres_backup_{db-name}__{timestamp}.pg_restore`

With the timestamp part look like this: `[Year].[Month].[Date].[Hour]_[Minutes]`
for example: `2018.11.27.10_36`

You can use this information to implement your own backup rotation scripts 
that will delete backup file that is considered old.

## Restoring backup file from other server

Let's say you have staging server with good data to replicate for your local environment.
You can copy over the backup file and restore it in your local environment.

Backup volumes were bind mounted to host for local development. 
Each service will have the following backup location (relative to `deployment` folder of this repo):

- kobocat: `backups/backups-kobocat`
- mongo: `backups/backups-mongo`
- postgres: `backups/backups-postgres`

For example, given a backup file called: `postgres_backup_kobotoolbox__2018.11.27.10_30.pg_restore`,
Put it into `deployment/backups/backups-postgres` directory.
Then, execute make command:
`make restore-postgres FILENAME=/srv/backups/postgres_backup_kobotoolbox__2018.11.27.10_30.pg_restore`
to restore the backup to your local environment.

