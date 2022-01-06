#!/bin/bash

LOG="/tmp/backup/backupCassandra.log"
SLACK_FILE="/tmp/backup/CasSlackmessage.log"
PATCH="/tmp/backup/backup_cassandra/"
DB="/var/lib/cassandra/data/thingsboard"
WEBHOOK=""
mkdir -p $PATCH

exec   > >(sudo tee -ia $LOG )
exec  2> >(sudo tee -ia $LOG >& 2)
exec   > >(sudo tee -i $SLACK_FILE)
exec  2> >(sudo tee -i $SLACK_FILE >& 2)

CUR_DATE=$(date +'%m-%d-%y_%H:%M')
echo "-------- Start backup process at ${CUR_DATE} --------"

AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo du -sm $DB |  awk '{print int($1)}')

echo "Free space: ${AVAIL} Mb"
echo "Cassandra DB size: ${FILESIZE} Mb"

if [ $(echo "$AVAIL<=$FILESIZE" | bc) -ge 1 ]
then
  echo " Not enought free space"
else
  echo " Enought free space"
  mkdir -p $PATCH
  sudo chmod -R o+rw $PATCH
    nodetool flush

    mkdir -p /tmp/backup
    cqlsh 127.0.0.1 -e "DESCRIBE KEYSPACE thingsboard;" > ${PATCH}thingsboard-describe.txt

    TARFILE=${PATCH}$CUR_DATE.cassandra.tar
    sudo tar -cvf "$TARFILE" /var/lib/cassandra/data/thingsboard ${PATCH}thingsboard-describe.txt
    rm -rf ${PATCH}thingsboard-describe.txt

    TARFILE_SIZE=$(du -m "$TARFILE" | awk '{print $1}')
    echo "Backup file size: ${TARFILE_SIZE} Mb"
    MINSIZE=1
    if [ $(echo "$TARFILE_SIZE<=$MINSIZE" | bc) -ge 1 ]
    then
      echo "WARNING. Backup file is less then 1 Mb"
    fi
fi

echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------\n"

SLACK_DATA="{\"text\":\"$(cat $SLACK_FILE)\"}"

curl -X POST -H 'Content-type: application/json' --data "$SLACK_DATA" "$WEBHOOK"