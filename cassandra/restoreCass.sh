#!/bin/bash
PATCH="/tmp/backup/"
BACKUP=${PATCH}"PASTE_BACKUP_FILENAME"

cd $PATCH || exit 
cqlsh 127.0.0.1 < thingsboard-describe.txt


sudo systemctl stop cassandra
sudo mkdir thingsboard && cd $_
sudo tar -xvf $BACKUP

CF=$(sudo find . -name "ts_kv_cf")
PARTITIONS_CF=$(sudo find . -name "ts_kv_partitions_cf")

sudo mv ${CF}* ./ts_kv_cf
sudo mv ${PARTITIONS_CF} ./ts_kv_partitions_cf

sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_partitions_cf/
sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_cf/

cd ..
sudo rm -rf thingsboard