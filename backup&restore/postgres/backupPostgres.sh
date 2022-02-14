#!/bin/bash

BACKUP_PATH="/home/${USER}/backup/postgres/"
LOG="${BACKUP_PATH}BackupPostgres.log"

WEBHOOK_FILE="${BACKUP_PATH}WebhookMessagePostgres.log"
WEBHOOK="https://yourwebhookendpoint.com/"


mkdir -p $BACKUP_PATH
sudo chmod -R o+rw $BACKUP_PATH
exec   > >(sudo tee -ia $LOG $WEBHOOK_FILE)
exec  2> >(sudo tee -ia $LOG $WEBHOOK_FILE >& 2)
truncate -s 0 $WEBHOOK_FILE 
find $BACKUP_PATH -mtime +3 -exec rm -f {} \; # delete backup older than * days

CUR_DATE=$(date +'%m-%d-%y_%H:%M')

echo "---- Start Postgres backup process at $(date +'%m-%d-%y_%H:%M') ----"

AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo -u postgres psql -c "SELECT pg_size_pretty( pg_database_size('thingsboard') );" | awk '{print $1}'| head -n 3 | tail -1)

echo "Free space: ${AVAIL} Mb"
echo "Postgresql size: ${FILESIZE} Mb"

if [ $FILESIZE -ge $AVAIL ]
then
  echo " Not enought free space"
else
  echo " Enought free space, starting..."

  SQLBAK=${BACKUP_PATH}$(date +'%m-%d-%y_%H:%M').thingsboard.sql.bak
  sudo su -l postgres --session-command "pg_dump thingsboard > $SQLBAK"

  SQLBAK_SIZE=$(du -m "$SQLBAK" | awk '{print $1}')
  echo "Completed. Backup file size: ${SQLBAK_SIZE} Mb"
 
  if [ 1 -ge $SQLBAK_SIZE ]
  then
    echo "WARN. Backup file is less then 1 Mb"
  fi
fi
echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------\n"

WEBHOOK_DATA="{\"text\":\"$(cat $WEBHOOK_FILE)\"}"
curl -X POST -H 'Content-type: application/json' --data "$WEBHOOK_DATA" "$WEBHOOK"
