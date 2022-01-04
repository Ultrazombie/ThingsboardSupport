#!/bin/bash

DIR=/home/support/tb-pe-3.2.2/cassandraBackup/thingsboard/ #type here your backup thingsboard dir

mv ${DIR}ts_kv_cf* ${DIR}ts_kv_cf
mv ${DIR}ts_kv_partitions_cf* ${DIR}ts_kv_partitions_cf

sstableloader --verbose --nodes 127.0.0.1 ${DIR}ts_kv_partitions_cf/
sstableloader --verbose --nodes 127.0.0.1 ${DIR}ts_kv_cf/
