#!/bin/bash

HOST="192.168.244.129"
cd "$HOME/backupTimescale/"
ls -l
echo "Please enter the path of directory backup (ex- 2021-12-22_14-22)"
read -p "Please enter the path of backup directory (ex- 2021-12-22_14-22)" -r INPUT
PATCH="/home/support/backupTimescale/${INPUT}"

PATCHDUMP="${PATCH}/backup.bak"

sudo service thingsboard stop
psql -h $HOST -U postgres -d postgres -c 'drop database "thingsboard";'

psql -h $HOST -U postgres -d postgres -c 'create database "thingsboard";'
psql -h $HOST -U postgres -d thingsboard -c 'CREATE EXTENSION timescaledb;'

psql -h $HOST -U postgres -d thingsboard -c 'SELECT timescaledb_pre_restore();'
pg_restore -h $HOST -U postgres -Fc -d thingsboard $PATCHDUMP
psql -h $HOST -U postgres -d thingsboard -c 'SELECT timescaledb_post_restore();'


# Restore hypertable
# PATCHSCHEMA="${PATCH}/schema.sql"
# PATCHDATA="${PATCH}/data.csv"
# psql -h $HOST -U postgres -d thingsboard < $PATCHSCHEMA
# psql -h $HOST -U postgres -d thingsboard -c "SELECT create_hypertable('"ts_kv"', '"ts"', chunk_time_interval => 604800000, if_not_exists => true);"
# psql -h $HOST -U postgres -d thingsboard -c "\COPY ts_kv FROM ${PATCHDATA} CSV"
sudo service thingsboard start
echo "done"