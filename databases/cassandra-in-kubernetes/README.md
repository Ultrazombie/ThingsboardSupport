Scripts for backup and restore Cassandra in Kubernetes
## Owerview  

In ***`dockerfiledir`*** you can find our scripts to backup and restore the thingsboard database in Cassandra.
`backupCassandra.sh` is a simple script for performing a database backup. 
- WORKDIR - This variable is responsible for location of backup and log files.
- TARFILE - This is the name of you backup .tar
- WEBHOOK - If you want to be notified after the process is finished you need to insert your own webhook endpoint.
- BACKUP_TTL_DAYS - set the deletion of files in the WORKDIR folder that have been changed more than several days ago.
- Next to the backup file will be a log file. Here you can track whether any errors occurred during backup.
- Script will calculate the amount of free space and database size, and either generate a warning or continue the backup.
- After a backup is created, you can see in logs the size of the backup file and make sure it contains information. Otherwise you will get a warning.

`backupCassandraToS3.sh` - performs a backup, sends a webhook message and sends your backup to the S3 repository in AWS. 

`restoreCassandra.sh` - the script restores the database. You only need to select the backup file path. Set backup path to BACKUP variable.

`dockerfile` - file to build a backup image.

## How it works

**Backup**
To perform a cassandra backup in Kubernetes, we have created scripts that are based on the cassandra image. 
We then create a deployment on the node where cassandra is located. In this way, the backup accesses the pvc that cassandra uses. When you start the backup pod, a script is run that archives the thingsboard location folder and the thingsboard keyspace data.
Optionally, you can use a second script which sends the archive to the S3 AWS repository.

**Restore**
Works on the same principle. The script opens the archive and uses *sstableloader* to upload the data back to cassandra.

**The webhook**
Has been added so that your team can see if the backup or restore was successful. Webhook uses logs, which you can see by running the command:
`kubectl logs -f CASSANDRA_BACKUP_POD`

## Preparing

1. You need to log in to docker under your docker account: `docker login`

2. Open the `build-docker-image.sh` file and set the **DOCKERHUB_NAME**, **VERSION**

3. Run the docker buid script: `./build-docker-image.sh`

4. Go to your docker hub and make sure that the image has been successfully built.

> In order for the backup pod to be able to use cassandra pvc, they must
 be on the same node. Labels are used for this. Run the command to
determine which node the cassandra pod is currently on: `kubectl get
 pods -o wide`
Then apply the tags:
 `kubectl label nodes YOUR_NODE_NAME cassandraNode=1`
 `kubectl label nodes YOUR_NODE_NAME role=cassandra`
These labels will be used by the nodeSelector.
  
## Running

Update your cassandara deployment as specified in the example `cassandara.yml`

> If you perform a backup without a scheduler, it is recommended to
 enter the cassandra pod and run the command (to load all data from RAM
 to pvc) : `nodetool flush`

**Simple backup** - choose `cassandra_simple_backup.yml`

1. Replace **YOUR_DOCKERHUB_NAME** to your own.

2. If you want to use a webhook, please uncomment the lines in the configuration. Then add your webhook url to kubernetes secrets:

    ```
    export WEBHOOK=YOUR_WEBHOOK_URL

    kubectl create -n thingsboard secret generic thingsboard \
    --from-literal=webhook-key=$WEBHOOK
    ```

3. You can replace **DB** variable and cassandra-data volume path if you using non-standart location for cassandra. The standart location is `/var/lib/cassandra/data/thingsboard`

4. Run `kubectl apply -f cassandra_simple_backup.yml`

**Backup with push to S3** - choose cassandra_simple_backup_s3.yml

1. Replace **YOUR_DOCKERHUB_NAME** to your own.

2. You can replace **DB** variable and cassandra-data volume path if you using non-standart location for cassandra. The standart location is `/var/lib/cassandra/data/thingsboard`

3. Set variables to send the backup to S3. Additionally, you can set a webhook url variable, and uncomment the lines in the configuration for webhook.

```
export WEBHOOK_URL=
export S3_BUCKET_URI=
export ACCESS_KEY=
export SECRET_KEY=
export HOST_BUCKET=

kubectl create -n thingsboard secret generic thingsboard \
--from-literal=webhook-key=$WEBHOOK_URL \
--from-literal=s3_bucket_uri-key=$S3_BUCKET_URI \
--from-literal=access-key=$ACCESS_KEY \
--from-literal=secret-key=$SECRET_KEY \
--from-literal=host_bucket-key=$HOST_BUCKET
```

4. Run `kubectl apply -f cassandra_s3_backup.yml`

**Scheduled backups**

You can schedule backups for a certain period of time. For this purpose, there are daily weekly and monthly cassadra_cron deployments. The backup can be stored internally in pod and on the AWS S3. They are configured in the same way as the simple ones.


**Restore** - choose cassandra_simple_restore.yml

1. Select which backup you want to use and replace **BACKUP_FILE** with the full path to the backup. The ***/data/backup/*** folder is used to store your backups. If you want to use a different backup file (e.g. one located on your machine) you can upload it to this folder: 
`kubectl cp YOUR_LOCAL_BACKUP_FILE_LOCATION CASSANDRA_POD:/data/backup/BACKUP_FILE_NAME`
2. Replace **YOUR_DOCKERHUB_NAME** to your own.
3. Go to cassandra pod and delete the thingsboard data:
    ```
    kubectl exec -it CASSNDRA_POD bash
    rm -rf var/lib/cassandra/data/thingsboard/*
    ```
4. Run `kubectl apply -f cassandra_simple_restore.yml`