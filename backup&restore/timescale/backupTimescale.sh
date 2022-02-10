#!/bin/bash

sudo mkdir -p ~/backupTimescale/"$(date +"%Y-%m-%d_%H-%M")" && cd "$_"
sudo chmod 777 ./
BACKUP_PATH=$(pwd)
HOST="192.168.244.129"
BACKUP_PATHDUMP="$BACKUP_PATH/backup.bak"
sudo pg_dump -h $HOST -U postgres -Fc -f "$BACKUP_PATHDUMP" thingsboard

