#!/bin/bash

PATCH="/tmp/backup/backup_psql/"


avail_in_kb=$(df -BK / | tail -1 | awk '{print $4}' | sed -r  's/^[^0-9]*([0-9]+).*/\1/')
filesize_in_bytes=$(du -s /var/lib/postgresql |  awk '{print int($1)}')
AVAIL=$(echo "scale=6; ${avail_in_kb/1024/1024}" | bc -l)
FILESIZE=$(echo "scale=6; ${filesize_in_bytes}/1024/1024/1024" | bc -l)
echo "Free space: ${AVAIL} Gb"
echo "Filesize: ${FILESIZE} Gb"

if [ $(echo "$AVAIL<=$FILESIZE" | bc) -ge 1 ]
then
  echo "Not enought free space"
else
  echo "Enought free space"
  mkdir -p $PATCH
  sudo chmod -R o+rw $PATCH
  CUR_DATE=$(date +'%m-%d-%y_%H:%M')
  SQLBAK=${PATCH}${CUR_DATE}.thingsboard.sql.bak
  sudo su -l postgres --session-command "pg_dump thingsboard > $SQLBAK"

  SQLBAK_SIZE=$(du "$SQLBAK" | awk '{print $1}')
  MINSIZE=100
  if [ $(echo "$SQLBAK_SIZE<=$MINSIZE" | bc) -ge 1 ]
  then
    echo -e "\033[31m WARNING. Backup file is less then 100Kb"
  fi
fi
