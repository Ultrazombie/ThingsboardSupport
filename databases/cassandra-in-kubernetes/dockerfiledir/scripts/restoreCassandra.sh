#!/bin/bash
WORKDIR="/data/restore/"

mkdir -p "${WORKDIR}"
chmod -R o+rw "${WORKDIR}"
cd "${WORKDIR}" || exit

WEBHOOK_FILE="WebhookMessageCassandra.log"
exec > >(tee -ia $LOG "${WEBHOOK_FILE}")
exec 2> >(tee -ia $LOG "${WEBHOOK_FILE}" >&2)
truncate -s 0 $WEBHOOK_FILE
echo -e "\n---- Start Cassandra restore process at $(date +'%d-%b-%y_%H:%M') ----"

if [[ -n "${BACKUP_FILE}" ]]; then

	tar -xf "${BACKUP_FILE}"

	CF=$(find . -name "ts_kv_cf*")
	PARTITIONS_CF=$(find . -name "ts_kv_partitions_cf*")
	LATEST=$(find . -name "ts_kv_latest*")
	DESCRIBE=$(find . -name "thingsboard-describe.txt")

	cqlsh <"${DESCRIBE}"
	mv "${CF}" ./ts_kv_cf
	mv "${PARTITIONS_CF}" ./ts_kv_partitions_cf

	cd "${WORKDIR}" || exit

	if [[ -n ${LATEST} ]]; then
		mv "${LATEST}" ./ts_kv_latest_cf
		sstableloader -d cassandra -v ./ts_kv_latest_cf 
	fi

	sstableloader -d cassandra  -k thingsboard ./ts_kv_cf 
	sstableloader -d cassandra  -k thingsboard ./ts_kv_partitions_cf 

	rm -rf ./*
else
	echo -e "BACKUP_FILE not found\n"
fi

echo -e "------- Backup process finished at $(date +'%d-%b-%y_%H:%M') -------\n"

sed -e "s/\r//g" $WEBHOOK_FILE > ${WEBHOOK_FILE}.mod

if [ "$WEBHOOK" ]; then
	WEBHOOK_DATA="{\"text\":\"$(cat $WEBHOOK_FILE)\"}"
	curl -X POST -H 'Content-type: application/json' --data "$WEBHOOK_DATA" "$WEBHOOK"
else
    echo -e "\n WEBHOOK URL is not specified"
fi
