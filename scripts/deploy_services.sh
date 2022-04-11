#!/usr/bin/env bash
set -e

PROJECT_NAME="$1"
QUANTITY="$2"

DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${PROJECT_NAME}.yml"
ECS_PARAMS_INPUT="./clusters/ecs-params.${PROJECT_NAME}.yml"

echo "Deploying ${QUANTITY} services on ${PROJECT_NAME} cluster (${AWS_REGION})"

for i in $(seq 1 $QUANTITY)
do 
    SERVICE_NAME="${PROJECT_NAME}-${i}"
    echo "### Doing: ${i}/${QUANTITY} ####"
    ecs-cli compose --project-name $SERVICE_NAME --file $DOCKER_COMPOSE_INPUT --ecs-params $ECS_PARAMS_INPUT --debug service up --region $AWS_REGION --ecs-profile $AWS_PROFILE --cluster-config $PROJECT_NAME

    echo "Service  deployed"
    echo "### Done: ${i} ####"
done

ecs-cli ps --cluster-config $PROJECT_NAME --desired-status RUNNING | awk 'NR>1 {print $3}'  | awk -F '-' '{print $1}' > proxies.txt
