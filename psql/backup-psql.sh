#!/bin/bash
LOG="/tmp/backup/backup_psql/BackupPostgres.log"
SLACK_FILE="/tmp/backup/backup_psql/SlackMessagePostgres.log"
PATCH="/tmp/backup/backup_psql/"
DB="/var/lib/postgresql"
WEBHOOK=""

mkdir -p $PATCH
sudo chmod -R o+rw $PATCH
exec   > >(sudo tee -ia $LOG $SLACK_FILE)
exec  2> >(sudo tee -ia $LOG $SLACK_FILE >& 2)
truncate -s 0 $SLACK_FILE

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

  SQLBAK=${PATCH}${CUR_DATE}.thingsboard.sql.bak
  sudo su -l postgres --session-command "pg_dump thingsboard > $SQLBAK"

  SQLBAK_SIZE=$(du -m "$SQLBAK" | awk '{print $1}')
  echo "Completed. Backup file size: ${SQLBAK_SIZE} Mb"
  MINSIZE=1
  if [ $(echo "$SQLBAK_SIZE<=$MINSIZE" | bc) -ge 1 ]
  then
    echo "WARNING. Backup file is less then 1 Mb"
  fi
fi
echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------\n"

SLACK_MESSAGE=$(cat $SLACK_FILE)
SLACK_DATA="{\"text\":\"$(cat $SLACK_FILE)\"}"

curl -X POST -H 'Content-type: application/json' --data "$SLACK_DATA" "$WEBHOOK"
