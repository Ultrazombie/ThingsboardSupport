#!/bin/bash
BACKUP_PATH="/home/${USER}/backup/cassandra/"
DB="/var/lib/cassandra/data/thingsboard"

mkdir -p $BACKUP_PATH
sudo chmod -R o+rw $BACKUP_PATH
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
    sudo tar -cvf "$TARFILE" -P /var/lib/cassandra/data/thingsboard ${BACKUP_PATH}thingsboard-describe.txt
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