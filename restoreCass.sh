#!/bin/bash
patch="/tmp/backup/"
backup=${patch}"PASTE_BACKUP_FILENAME"

cd patch || exit 
cqlsh 127.0.0.1 < thingsboard-describe.txt


sudo systemctl stop cassandra
sudo mkdir thingsboard && cd $_
sudo tar -xvf $backup

#Make sure that script is located  inside backup directory near ts_kv_* files.
sudo mv ./ts_kv_cf* ./ts_kv_cf
sudo mv ./ts_kv_partitions_cf* ./ts_kv_partitions_cf

sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_partitions_cf/
sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_cf/

cd ..
sudo rm -rf thingsboard