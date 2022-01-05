#!/bin/bash
PATCH="/pon0mar/backup/"
BACKUP=${PATCH}"01-04-22_16_26.cassandra.tar"

cd $PATCH || exit 
cqlsh 127.0.0.1 < thingsboard-describe.txt


sudo mkdir thingsboard && cd $_
sudo tar -xvf $BACKUP


CF=$(sudo find . -name "ts_kv_cf*")
PARTITIONS_CF=$(sudo find . -name "ts_kv_partitions_cf*")

sudo mv ${CF} ./ts_kv_cf
sudo mv ${PARTITIONS_CF} ./ts_kv_partitions_cf

cd $PATCH || exit

sudo sstableloader --verbose --nodes 127.0.0.1 ./thingsboard/ts_kv_partitions_cf
sudo sstableloader --verbose --nodes 127.0.0.1 ./thingsboard/ts_kv_cf

sudo rm -rf thingsboard 