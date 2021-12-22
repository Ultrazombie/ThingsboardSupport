#!/bin/bash

sudo mkdir -p ~/backupTimescale/"$(date +"%Y-%m-%d_%Hh%Mm")" && cd "$_"
sudo chmod 777 ./
PATCH=$(pwd)
HOST="192.168.244.129"
PATCHDUMP="$PATCH/backup.bak"
PATCHSCHEMA="$PATCH/schema.sql"
PATCHDATA="$PATCH/data.csv"


sudo pg_dump -h $HOST -U postgres -Fc -f "$PATCHDUMP" thingsboard
sudo pg_dump -h $HOST -U postgres -s -d thingsboard --table ts_kv -N _timescaledb_internal | grep -v _timescaledb_internal > "$PATCHSCHEMA"
psql -h $HOST -U postgres -d thingsboard \
  -c "\COPY (SELECT * FROM ts_kv) TO ${PATCHDATA} DELIMITER ',' CSV"


# service thingsboard stop

# psql -h $HOST -U postgres -d postgres -c 'drop database "thingsboard"'

# psql -h $HOST -U postgres -d postgres -c 'create database "thingsboard"'
# psql -h $HOST -U postgres -d thingsboard -c 'CREATE EXTENSION timescaledb'
# psql -h $HOST -U postgres -d thingsboard -c 'SELECT timescaledb_pre_restore();'

# pg_restore -h $HOST -U postgres -Fc -d thingsboard backup.bak

# psql -h $HOST -U postgres -d thingsboard < schema.sql
# psql -h $HOST -U postgres -d thingsboard -c "SELECT create_hypertable('ts_kv')"
# psql -h $HOST -U postgres -d new_db -c "\COPY ts_kv FROM data.csv CSV"

# service thingsboard start




psql -h $HOST -U postgres  -d thingsboard -c "SELECT timescaledb_post_restore();"