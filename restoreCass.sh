#!/bin/bash

#Make sure that script is located  inside backup directory near ts_kv_* files.
mv ./ts_kv_cf* ./ts_kv_cf
mv ./ts_kv_partitions_cf* ./ts_kv_partitions_cf

sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_partitions_cf/
sstableloader --verbose --nodes 127.0.0.1 ./ts_kv_cf/
