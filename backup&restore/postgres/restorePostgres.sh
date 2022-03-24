#!/bin/bash
psql -U postgres -h localhost -c "drop database thingsboard"
psql -U postgres -h localhost -c "create database thingsboard"
psql -U postgres -d thingsboard -W< /home/${USER}/backup/postgres/.thingsboard.sql.bak
