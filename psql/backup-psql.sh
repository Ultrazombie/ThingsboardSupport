#!/bin/bash
LOG="/tmp/backup/backup.log"
SLACK_FILE="/tmp/backup/slackmessage.log"
PATCH="/tmp/backup/backup_psql/"
DB="/var/lib/postgresql"
WEBHOOK=""


exec   > >(sudo tee -ia $LOG )
exec  2> >(sudo tee -ia $LOG >& 2)
exec   > >(sudo tee -i $SLACK_FILE)
exec  2> >(sudo tee -i $SLACK_FILE >& 2)

CUR_DATE=$(date +'%m-%d-%y_%H:%M')
echo "-------- Start backup process at ${CUR_DATE} --------"

AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo du -sm $DB |  awk '{print int($1)}')

echo "Free space: ${AVAIL} Mb"
echo "Postgresql size: ${FILESIZE} Mb"

if [ $(echo "$AVAIL<=$FILESIZE" | bc) -ge 1 ]
then
  echo " Not enought free space"
else
  echo " Enought free space"
  mkdir -p $PATCH
  sudo chmod -R o+rw $PATCH
  SQLBAK=${PATCH}${CUR_DATE}.thingsboard.sql.bak
  sudo su -l postgres --session-command "pg_dump thingsboard > $SQLBAK"

  SQLBAK_SIZE=$(du -m "$SQLBAK" | awk '{print $1}')
  echo "Backup file size: ${SQLBAK_SIZE} Mb"
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
