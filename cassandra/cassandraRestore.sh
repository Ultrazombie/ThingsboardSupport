#!/bin/bash
sudo systemctl stop cassandra
read -p "Please Enter Path: " -r patch
cd /var/lib/cassandra/ || exit
sudo tar -xvf $patch
sudo chown -R cassandra. /var/lib/cassandra/

sudo systemctl start cassandra
