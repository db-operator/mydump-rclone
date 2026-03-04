#!/bin/bash
set -e

echo "Prepare configuration for script"
TIMESTAMP=$(date +%F_%R)
BACKUP_FILE=${DB_NAME}-${TIMESTAMP}.sql
BACKUP_FILE_LATEST=${DB_NAME}-latest.sql.gz
DB_HOST=${DB_HOST:-localhost}
DB_PASSWORD=$(cat ${DB_PASSWORD_FILE})

if [[ -z "${STORAGE_BUCKET}" ]]; then
  echo "Variable STORAGE_BUCKET must be set"
  exit 1
fi

# create login credential file
echo "[mysqldump]
password=${DB_PASSWORD}" > ~/.my.cnf
chmod 0600 ~/.my.cnf

echo "Start creating backup"
mariadb-dump -h ${DB_HOST} -u ${DB_USER} -P ${DB_PORT} --single-transaction --dump-date ${DB_NAME} > ${BACKUP_FILE}
if [[ $? -eq 0 ]]; then
    gzip ${BACKUP_FILE}
else 
    echo >&2 "DB backup failed" 
    exit 1
fi

## copy to destination
echo "Upload to storage"
BACKUP_FILE_ARCHIVED=${BACKUP_FILE}.gz

rclone copyto "./${BACKUP_FILE_ARCHIVED}" "storage://${STORAGE_BUCKET}/${DB_NAME}/${BACKUP_FILE_ARCHIVED}" 
rclone copyto "./${BACKUP_FILE_ARCHIVED}" "storage://${STORAGE_BUCKET}/${DB_NAME}/${BACKUP_FILE_LATEST}" 

if test $? -ne 0 
then
	exit 1;
fi
