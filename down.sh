#!/usr/bin/env bash
set -e
source setenv.sh

PROJECT_NAME="$1"
QUANTITY="$2"

for i in $(seq 1 $QUANTITY)
do 
    echo "### Shutdown ${PROJECT_NAME}-${i} (${i}/${QUANTITY}) ####"
    ## Erase services
    # ecs-cli compose --project-name "${PROJECT_NAME}" service down --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}-${i}"

    aws ecs update-service --desired-count 0 --cluster "${PROJECT_NAME}" --service "${PROJECT_NAME}-${i}" >> /dev/null

    echo "### Done: ${PROJECT_NAME}-${i} ####"
done
echo "" > proxies.txt
