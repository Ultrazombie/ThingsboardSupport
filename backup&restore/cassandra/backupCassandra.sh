#!/bin/bash
LOG="/tmp/backup/backup_cassandra/BackupCassandra.log"
BACKUP_PATH="/tmp/backup/backup_cassandra/"
DB="/var/lib/cassandra/data/thingsboard"

WEBHOOK_FILE="/tmp/backup/backup_cassandra/WebhookMessageCassandra.log"
WEBHOOK="https://yourwebhookendpoint.com/"

mkdir -p $BACKUP_PATH
sudo chmod -R o+rw $BACKUP_PATH
exec   > >(sudo tee -ia $LOG $WEBHOOK_FILE)
exec  2> >(sudo tee -ia $LOG $WEBHOOK_FILE >& 2)
truncate -s 0 $WEBHOOK_FILE
find $BACKUP_PATH -mtime +3 -exec rm -f {} \; # delete backup older than * days

CUR_DATE=$(date +'%m-%d-%y_%H:%M')
echo -e "\n-------- Start Cassandra backup process at ${CUR_DATE} --------"

AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo du -sm $DB |  awk '{print int($1)}')

echo "Free space: ${AVAIL} Mb"
echo "Cassandra DB size: ${FILESIZE} Mb"

if [ $(echo "$AVAIL<=$FILESIZE" | bc) -ge 1 ]
then
  echo " Not enought free space"
else
    echo " Enought free space, starting..."

    nodetool flush
    cqlsh 127.0.0.1 -e "DESCRIBE KEYSPACE thingsboard;" > ${BACKUP_PATH}thingsboard-describe.txt

    TARFILE=$BACKUP_PATH$CUR_DATE.cassandra.tar
    sudo tar -cvf "$TARFILE" -P /var/lib/cassandra/data/thingsboard ${BACKUP_PATH}thingsboard-describe.txt > tarlog.log
    rm -rf ${BACKUP_PATH}thingsboard-describe.txt

    TARFILE_SIZE=$(du -m "$TARFILE" | awk '{print $1}')
    echo "Completed. Backup file size: ${TARFILE_SIZE} Mb"
    MINSIZE=1
    if [ $(echo "$TARFILE_SIZE<=$MINSIZE" | bc) -ge 1 ]
    then
      echo "WARNING. Backup file is less then 1 Mb"
    fi
fi
echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------"

WEBHOOK_DATA="{\"text\":\"$(cat $WEBHOOK_FILE)\"}"
curl -X POST -H 'Content-type: application/json' --data "$WEBHOOK_DATA" "$WEBHOOK"