#!/usr/bin/env bash
source setenv.sh

PROJECT_NAME="$1"

# cleanup aws log group
# aws logs delete-log-group --log-group-name $PROJECT_NAME

CLEAN_PROJECT_NAME=$(echo ${PROJECT_NAME} | awk -F '-' '{print $1}')
DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${CLEAN_PROJECT_NAME}.yml"
ECS_PARAMS_INPUT="./clusters/ecs-params.${PROJECT_NAME}.yml"

# # clean up ecs cluster
ecs-cli compose --file "${DOCKER_COMPOSE_INPUT}" --ecs-params "${ECS_PARAMS_INPUT}" --project-name "${PROJECT_NAME}" service down --cluster-config "${PROJECT_NAME}"
ecs-cli down --force --cluster-config "${PROJECT_NAME}"

rm $ECS_PARAMS_INPUT
