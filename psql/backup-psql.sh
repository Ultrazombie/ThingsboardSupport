#!/bin/bash

avail_in_kb=$(df -BK / | tail -1 | awk '{print $4}' | sed -r  's/^[^0-9]*([0-9]+).*/\1/')
filesize_in_bytes=$(du -s /var/lib/postgresql |  awk '{print int($1)}')
avail=`echo "scale=6; $avail_in_kb/1024/1024" | bc -l`
filesize=`echo "scale=6; $filesize_in_bytes/1024/1024/1024" | bc -l`
echo "$avail"
echo "$filesize"

if [ `echo "$avail<=$filesize" | bc` -ge 1 ]
then
#not enought free space
echo "not enought space"
else
#make backup
echo "enought space"
sudo su -l postgres --session-command "pg_dump thingsboard > /home/support/backup_psql/'$current_date'.thingsboard.sql.bak"
fi
