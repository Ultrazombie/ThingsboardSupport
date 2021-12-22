#!/bin/bash

sudo mkdir -p ~/backupTimescale/"$(date +"%Y-%m-%d_%H-%M")" && cd "$_"
sudo chmod 777 ./
PATCH=$(pwd)
HOST="192.168.244.129"
PATCHDUMP="$PATCH/backup.bak"
sudo pg_dump -h $HOST -U postgres -Fc -f "$PATCHDUMP" thingsboard


# PATCHSCHEMA="$PATCH/schema.sql"
# PATCHDATA="$PATCH/data.csv"
# sudo pg_dump -h $HOST -U postgres -s -d thingsboard --table ts_kv -N _timescaledb_internal | grep -v _timescaledb_internal > "$PATCHSCHEMA"
# psql -h $HOST -U postgres -d thingsboard \
#   -c "\COPY (SELECT * FROM ts_kv) TO ${PATCHDATA} DELIMITER ',' CSV"
