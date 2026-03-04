# MySQL backup container for DB Operator

Small docker container for creating a backup of a musql database and uploading it to an external storage using rclone.

Every backup is uploaded twice, once with a **timestamp** and once as **latest**. So you can always download the latest backup.

There is no clean-up logic, please take care of old backups using external tools, for example bucket retention policies.

## How to restore

You need to unzip the backup file and restore it with `mysql` cli:
```shell
$ gzip -dk <Path to the backup archive>
$ mysql -u <Admin user> --password=<Admin password> -h <Database host>  -P <Database Port> --database working_namespace_mysql < <Path to backup>
```

## How to use

This container is supposed to be used by the DB Operator for setting up backup CronJobs. 

To backup a mysql/mariadb database using this container you need to pass env variables for `mariadb-dump` and for `rclone`:

**mariadb-dump** variables:

- **DB_NAME**: A name of a database to back up
- **DB_PORT**: A port on which database is listening
- **DB_HOST**: A database server host
- **DB_PASSWORD_FILE**: A path to a file with a database password (file must be mounted to the container)
- **DB_USER**: User that should perform the backup

**rclone** variables:

- **STORAGE_BUCKET**: A name of a bucket/directory that should be used for uploading the backup

For the rest, please check here: <https://rclone.org/docs/#environment-variables>.

The backend name is hardcoded to 'storage', so your env vars should be prefixed by `RCLONE_CONFIG_STORAGE_`

