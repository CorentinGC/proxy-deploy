#!/usr/bin/env bash
# set -e

PROJECT_NAME="$1"
QUANTITY="$2"

for i in $(seq 1 $QUANTITY)
do 
    echo "### Doing: ${i}/${QUANTITY} ####"
    ecs-cli compose --project-name "${PROJECT_NAME}" service down --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}-${i}"
    echo "### Done: ${i} ####"
done
