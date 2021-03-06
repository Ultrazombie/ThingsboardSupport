#!/bin/bash
PATCH="/tmp/backup/"
BACKUP=${PATCH}"YOU_CASSANDRA_BACKUP"

cd $PATCH || exit 

sudo mkdir thingsboard && cd thingsboard
sudo tar -xvf $BACKUP

CF=$(sudo find . -name "ts_kv_cf*")
PARTITIONS_CF=$(sudo find . -name "ts_kv_partitions_cf*")
LATEST=$(sudo find . -name "ts_kv_latest*")
DESCRIBE=$(sudo find . -name "thingsboard-describe.txt")

cqlsh 127.0.0.1 < $DESCRIBE
sudo mv ${CF} ./ts_kv_cf
sudo mv ${PARTITIONS_CF} ./ts_kv_partitions_cf

cd $PATCH || exit

if [[ $LATEST ]]
then
  sudo mv ${LATEST} ./thingsboard/ts_kv_latest_cf
  sudo sstableloader --verbose --nodes 127.0.0.1 ./thingsboard/ts_kv_latest_cf
fi

sudo sstableloader --verbose --nodes 127.0.0.1 ./thingsboard/ts_kv_partitions_cf
sudo sstableloader --verbose --nodes 127.0.0.1 ./thingsboard/ts_kv_cf

 sudo rm -rf thingsboard   
