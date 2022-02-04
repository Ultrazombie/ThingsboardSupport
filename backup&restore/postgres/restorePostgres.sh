#!/bin/bash

psql -U postgres -d thingsboard -W< /home/support/backup_psql/.thingsboard.sql.bak
