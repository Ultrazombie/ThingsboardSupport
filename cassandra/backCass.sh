#!/bin/bash

WEBHOOK=""

DB="/var/lib/cassandra/data/thingsboard"

exec   > >(sudo tee -ia $LOG )
exec  2> >(sudo tee -ia $LOG >& 2)
exec   > >(sudo tee -i $SLACK_FILE)
exec  2> >(sudo tee -i $SLACK_FILE >& 2)


current_date=$(date +'%m-%d-%y_%H:%M')

avail_in_Kb=$(df -BK / | tail -1 | awk '{print $4}' | sed -r  's/^[^0-9]*([0-9]+).*/\1/')
filesize_in_bytes=$(du -s /var/lib/cassandra/data/thingsboard |  awk '{print int($1)}')
avail=$(echo "scale=6; $avail_in_Kb/1024/1024" | bc -l)
filesize=$(echo "scale=6; $filesize_in_bytes/1024/1024/1024" | bc -l)
echo "$avail"
echo "$filesize"

if [ $(echo "$avail<=$filesize" | bc) -ge 1 ]
then
  echo "Not enought free space"
else
  echo "Enought free space"

    nodetool flush

    mkdir -p /tmp/backup
    cqlsh 127.0.0.1 -e "DESCRIBE KEYSPACE thingsboard;" > /tmp/backup/thingsboard-describe.txt

    TARFILE=/tmp/backup/$current_date.cassandra.tar
    sudo tar -cvf "$TARFILE" /var/lib/cassandra/data/thingsboard /tmp/backup/thingsboard-describe.txt
    rm -rf /tmp/backup/thingsboard-describe.txt

    TARFILE_SIZE=$(du "$TARFILE" | awk '{print $1}')
    MINSIZE=100
    if [ $(echo "$TARFILE_SIZE<=$MINSIZE" | bc) -ge 1 ]
    then
        echo -e "\033[31m WARNING. Backup file is less then 100Kb"
    fi
fi

