#!/usr/bin/env bash
set -e

source ./.env

for file in ./clusters/*
do
    FILE=$(echo ${file} | awk -F '/' '{print $3}' | awk -F '.' '{printf $1}')
    CLUSTER=$(echo ${file} | awk -F '/' '{print $3}' | awk -F '.' '{printf $2}')

    if [ $FILE == 'docker-compose' ]
    then
        PROJECT_NAME=$(echo ${file} | awk -F '/' '{print $3}' | awk -F '.' '{printf $2}')
        echo "##### Doing: ${PROJECT_NAME}"

        DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${PROJECT_NAME}.yml"
        ECS_PARAMS_INPUT="./clusters/ecs-params.${PROJECT_NAME}.yml"

        ecs-cli compose --project-name "${PROJECT_NAME}" --file "${DOCKER_COMPOSE_INPUT}" --ecs-params "${ECS_PARAMS_INPUT}" --debug service up --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}"
    fi

done