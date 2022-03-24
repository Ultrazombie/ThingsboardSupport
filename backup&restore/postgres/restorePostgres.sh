#!/bin/bash
psql -U postgres -c "drop database thingsboard"
psql -U postgres -c "create database thingsboard"
psql -U postgres -d thingsboard -W< /home/${USER}/backup/postgres/.thingsboard.sql.bak
