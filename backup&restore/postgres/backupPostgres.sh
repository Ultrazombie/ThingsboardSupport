#!/bin/bash
LOG="/tmp/backup/backup_postgres/BackupPostgres.log"
BACKUP_PATH="/tmp/backup/backup_postgres/"
DB="/var/lib/postgresql"

WEBHOOK_FILE="/tmp/backup/backup_postgres/WebhookMessagePostgres.log"
WEBHOOK="https://yourwebhookendpoint.com/"


mkdir -p $BACKUP_PATH
sudo chmod -R o+rw $BACKUP_PATH
exec   > >(sudo tee -ia $LOG $WEBHOOK_FILE)
exec  2> >(sudo tee -ia $LOG $WEBHOOK_FILE >& 2)
truncate -s 0 $WEBHOOK_FILE 
find $BACKUP_PATH -mtime +3 -exec rm -f {} \; # delete backup older than * days

CUR_DATE=$(date +'%m-%d-%y_%H:%M')

echo "-------- Start Postgres backup process at ${CUR_DATE} --------"

AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo du -sm $DB |  awk '{print int($1)}')

echo "Free space: ${AVAIL} Mb"
echo "Postgresql size: ${FILESIZE} Mb"

if [ $(echo "$AVAIL<=$FILESIZE" | bc) -ge 1 ]
then
  echo " Not enought free space"
else
  echo " Enought free space, starting..."

  SQLBAK=${BACKUP_PATH}${CUR_DATE}.thingsboard.sql.bak
  sudo su -l postgres --session-command "pg_dump thingsboard > $SQLBAK"

  SQLBAK_SIZE=$(du -m "$SQLBAK" | awk '{print $1}')
  echo "Completed. Backup file size: ${SQLBAK_SIZE} Mb"
  MINSIZE=1
  if [ $(echo "$SQLBAK_SIZE<=$MINSIZE" | bc) -ge 1 ]
  then
    echo "WARN. Backup file is less then 1 Mb"
  fi
fi
echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------\n"

WEBHOOK_DATA="{\"text\":\"$(cat $WEBHOOK_FILE)\"}"
curl -X POST -H 'Content-type: application/json' --data "$WEBHOOK_DATA" "$WEBHOOK"
