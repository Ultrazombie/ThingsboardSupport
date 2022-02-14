#!/bin/bash
BACKUP_PATH="/home/${USER}/backup/postgres/"
DB="/var/lib/postgresql"

mkdir -p $BACKUP_PATH
sudo chmod -R o+rw $BACKUP_PATH

echo "---- Start Postgres backup process at $(date +'%m-%d-%y_%H:%M') ----"
AVAIL=$(df -m / | awk '{print $4}' | tail -1 )
FILESIZE=$(sudo -u postgres psql -c "SELECT pg_size_pretty( pg_database_size('thingsboard') );" | awk '{print $1}'| head -n 3| tail -1)

echo "Free space: ${AVAIL} Mb"
echo "Postgresql size: ${FILESIZE} Mb"

if [ $FILESIZE -ge $AVAIL ]
then
  echo " Not enought free space"
else
  echo " Enought free space, starting..."

  SQLBAK=${BACKUP_PATH}$(date +'%m-%d-%y_%H:%M').thingsboard.sql.bak
  sudo -Hiu postgres pg_dump thingsboard > $SQLBAK

  SQLBAK_SIZE=$(du -m "$SQLBAK" | awk '{print $1}')
  echo "Completed. Backup file size: ${SQLBAK_SIZE} Mb"
  if [ 1 -ge $SQLBAK_SIZE ]
  then
    echo "WARN. Backup file is less then 1 Mb"
  fi
fi
echo -e "------- Backup process finished at $(date +'%m-%d-%y_%H:%M') -------\n"

