#!/bin/bash
function cassandraBackup(){
avail_in_kb=$(df -BK / | tail -1 | awk '{print $4}' | sed -r  's/^[^0-9]*([0-9]+).*/\1/')
filesize_in_bytes=$(du -ks /var/lib/cassandra/ | tail -1 | awk '{print int($1)}')
echo "$(($avail_in_kb*1024))"
echo "$(($filesize_in_bytes))"

if [ "$(($avail_in_kb*1024))" -lt "$(($filesize_in_bytes))" ]
    then
    echo "Not enough free space"
else
    echo "Enough free space"

    nodetool drain
    sudo systemctl stop cassandra
    mkdir /backupCassandra/
    cd /var/lib/cassandra/
    patch="/backupCassandra/cassandra_$(date +"%Y-%m-%d_%Hh%Mm").tar"
    echo "Creating backup ${patch}. Adding files"
    sudo tar -cvf $patch *

fi    
}


while true
do
cassandraBackup
sleep 30s
done

