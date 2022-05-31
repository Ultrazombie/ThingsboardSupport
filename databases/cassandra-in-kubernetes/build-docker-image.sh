#!/bin/bash

# Go to dockerfile directory
cd ./dockerfiledir || exit

# Change DOCKERHUB_NAME and VERSION
DOCKERHUB_NAME=
VERSION=latest
docker build -t "${DOCKERHUB_NAME}"/k8s-backup:"${VERSION}" .
docker push "${DOCKERHUB_NAME}"/k8s-backup:"${VERSION}"
