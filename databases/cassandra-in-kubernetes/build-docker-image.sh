#!/bin/bash

# Go to dockerfile directory
cd tb/backup/dockerfiledir || exit

# Replace YOU_DOCKERHUB_NAME and VERSION
docker build -t YOU_DOCKERHUB_NAME/k8s-backup:VERSION .
docker push YOU_DOCKERHUB_NAME/k8s-backup:VERSION