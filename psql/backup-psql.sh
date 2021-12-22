#!/bin/bash

current_date=$(date +%Y%m%d-%H%M)
avail_in_kb=$(df -BK / | tail -1 | awk '{print $4}' | sed -r  's/^[^0-9]*([0-9]+).*/\1/')
db_size=`sudo su -l postgres -c "psql -t -c \"select pg_database_size('thingsboard')\""`
avail=`echo "scale=6; $avail_in_kb/1024/1024" | bc -l`
filesize=`echo "scale=6; $db_size/1024/1024/1024" | bc -l`
echo "$avail"
echo "$filesize"

if [ `echo "$avail<=$filesize" | bc` -ge 1 ]
then
#not enought free space
echo "not enought space"
else
#make backup
echo "enought space"
sudo su -l postgres --session-command "pg_dump thingsboard > /home/support/backup_psql/${current_date}_thingsboard.sql.bak"
echo "backup done"
fi
#deleting backups older then 1 day
find /home/support/backup_psql/* -mtime +1 -exec rm {} \; 
