#!/usr/bin/env bash
set -e

source ./.env

for file in ./clusters/*
do
    FILE=$(echo ${file} | awk -F '/' '{print $3}' | awk -F '.' '{printf $1}')

    if [ $FILE == 'ecs-params' ]
    then
        PROJECT_NAME=$(echo ${file} | awk -F '/' '{print $3}' | awk -F '.' '{printf $2}')
        echo "##### Doing: ${PROJECT_NAME}"
        CLEAN_PROJECT_NAME=$(echo ${PROJECT_NAME} | awk -F '-' '{print $1}')

        /usr/bin/bash ./scripts/destroy.sh "${PROJECT_NAME}"
    fi
done

DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${CLEAN_PROJECT_NAME}.yml"
rm $CLEAN_PROJECT_NAME
