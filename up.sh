#!/usr/bin/env bash
set -e
source setenv.sh

PROJECT_NAME="$1"
QUANTITY="$2"

for i in $(seq 1 $QUANTITY)
do 
    echo "### Powerup ${PROJECT_NAME}-${i} (${i}/${QUANTITY}) ####"
    ## Erase services
    # ecs-cli compose --project-name "${PROJECT_NAME}" service down --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}-${i}"

    aws ecs update-service --desired-count 1 --cluster "${PROJECT_NAME}" --service "${PROJECT_NAME}-${i}" >> /dev/null

    echo "### Done: ${PROJECT_NAME}-${i} ####"
done

WAIT=20
echo "Waiting ${WAIT}sec for container boot"
sleep $WAIT
ecs-cli ps --cluster-config ${PROJECT_NAME} --desired-status RUNNING | awk 'NR>1 {print $3}'  | awk -F '-' '{print $1}' > proxies.txt
