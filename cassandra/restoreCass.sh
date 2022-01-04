#!/bin/bash
PATCH="/tmp/backup/"
BACKUP=${PATCH}"PASTE_BACKUP_FILENAME"

cd $PATCH || exit 
cqlsh 127.0.0.1 < thingsboard-describe.txt


sudo systemctl stop cassandra
sudo mkdir thingsboard && cd $_
sudo tar -xvf $BACKUP

sudo mv ./ts_kv_cf* ./ts_kv_cf
sudo mv ./ts_kv_partitions_cf* ./ts_kv_partitions_cf

sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_partitions_cf/
sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_cf/

cd ..
sudo rm -rf thingsboard