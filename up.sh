#!/usr/bin/env bash
set -e

PROJECT_NAME="$1"
QUANTITY="$2"

DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${PROJECT_NAME}.yml"
ECS_PARAMS_INPUT="./clusters/ecs-params.${PROJECT_NAME}.yml"

echo "Deploying ${PROJECT_NAME}"

for i in $(seq 1 $QUANTITY)
do 
    echo "### Doing: ${i}/${QUANTITYe} ####"
    ecs-cli compose --project-name "${PROJECT_NAME}-${i}" --file "${DOCKER_COMPOSE_INPUT}" --ecs-params "${ECS_PARAMS_INPUT}" --debug service up --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}"

    echo "Container deployed"

    echo "### Done: ${i} ####"
done

ecs-cli ps --cluster-config ${PROJECT_NAME} --desired-status RUNNING | awk 'NR>2 {print $3}'  | awk -F '-' '{print $1}' >> proxies.txt
