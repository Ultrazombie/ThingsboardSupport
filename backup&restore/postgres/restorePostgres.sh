#!/bin/bash

psql -U postgres -d thingsboard -W< /home/${USER}/backup/postgres/.thingsboard.sql.bak
