#!/usr/bin/env bash
# set -e

PROJECT_NAME="$1"
QUANTITY="$2"

for i in $(seq 1 $QUANTITY)
do 
    echo "### Doing: ${i}/${QUANTITY} ####"
    ## Erase services
    # ecs-cli compose --project-name "${PROJECT_NAME}" service down --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}-${i}"

    aws ecs update-service --desired-count 1 --cluster "${PROJECT_NAME}" --service "${PROJECT_NAME}-${i}" >> /dev/null

    echo "### Done: ${i} ####"
done
ecs-cli ps --cluster-config ${PROJECT_NAME} --desired-status RUNNING | awk 'NR>2 {print $3}'  | awk -F '-' '{print $1}' > proxies.txt
