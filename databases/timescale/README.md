Scripts for backup and restore PostgreSQL


## Owerview

Here you can find our scripts to backup and restore the thingsboard database in postgres. 

`backupTimescale.sh` is a complete script for performing a database backup. It is recommended to use it on schedule with cron. 

- BACKUP_PATH - This variable is responsible for location of backup and log files. You can change it to your own.
- HOSTNAME - Point to the address where your database is located.
- WEBHOOK - If you want to be notified after the process is finished you need to insert your own webhook endpoint.
- `Find $BACKUP_PATH -mtime +3 -exec rm -f {} \;` -- this line will set the deletion of files in the BACKUP_PATH folder that have been changed more than 3 days ago. 
- Next to the backup file will be a log file. Here you can track whether any errors occurred during backup.
- Script will calculate the amount of free space and database size, and either generate a warning or continue the backup.
- After a backup is created, you can see in logs the size of the backup file and make sure it contains information. Otherwise you will get a warning.

`simpleBackupTimescale.sh` is a simplified script which can be used to run manually, e.g. if you need to make a backup before upgrading. It performs the same functions as the previous one except for logging and sending a webhook message 

`restoreTimescale.sh` - The script restores the database. You only need to select the backup file path after "<"

## Running

 **Backup**:                                                
1. You dont need to stop Postgres for perform backup
2. Before running backup script you can change BACKUP_PATH to your own path.
3. If you want to use webhook, you need to insert the endpoint of your webhook into WEBHOOK.

 **Restore**:
1. You dont need to stop Postgres for perform restore
2. Change the backup file path after "<" in restoreTimescale.sh to your actual path to the backup .sql.bak file.
3. Run restoreTimescale.sh
4. Login to your ThingsBoard instance and check that everything is OK.