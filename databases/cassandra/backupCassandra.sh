#!/bin/bash
BACKUP_PATH="/home/${USER}/backup/cassandra/"
LOG="${BACKUP_PATH}BackupCassandra.log"
DB="/var/lib/cassandra/data/thingsboard"
WEBHOOK_FILE="${BACKUP_PATH}WebhookMessageCassandra.log"
WEBHOOK="https://yourwebhookendpoint.com/"

mkdir -p $BACKUP_PATH
sudo chmod -R o+rw $BACKUP_PATH
exec   > >(sudo tee -ia $LOG $WEBHOOK_FILE)
exec  2> >(sudo tee -ia $LOG $WEBHOOK_FILE >& 2)
truncate -s 0 $WEBHOOK_FILE
find $BACKUP_PATH -mtime +3 -exec rm -f {} \; # delete backup older than * days

echo -e "\n---- Start Cassandra backup process at $(date +'%m-%d-%y_%H:%M') ----"

AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo du -sm $DB |  awk '{print int($1)}')

echo "Free space: ${AVAIL} Mb"
echo "Cassandra DB size: ${FILESIZE} Mb"

if [ $FILESIZE -ge $AVAIL ]
then
  echo " Not enought free space"
else
    echo " Enought free space, starting..."

    nodetool flush
    cqlsh 127.0.0.1 -e "DESCRIBE KEYSPACE thingsboard;" > ${BACKUP_PATH}thingsboard-describe.txt

    TARFILE=${BACKUP_PATH}$(date +'%m-%d-%y_%H:%M').cassandra.tar
    sudo tar -cf "$TARFILE" -P /var/lib/cassandra/data/thingsboard ${BACKUP_PATH}thingsboard-describe.txt
    rm -rf ${BACKUP_PATH}thingsboard-describe.txt

    TARFILE_SIZE=$(du -m "$TARFILE" | awk '{print $1}')
    echo "Completed. Backup file size: ${TARFILE_SIZE} Mb"
    MINSIZE=1
    if [ 1 -ge $TARFILE_SIZE ]
    then
      echo "WARN. Backup file is less then 1 Mb"
    fi
fi
echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------\n"

WEBHOOK_DATA="{\"text\":\"$(cat $WEBHOOK_FILE)\"}"
curl -X POST -H 'Content-type: application/json' --data "$WEBHOOK_DATA" "$WEBHOOK"