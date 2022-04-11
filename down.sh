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

        ecs-cli compose --project-name "${PROJECT_NAME}" service down --region "${AWS_REGION}" --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}"
    fi

done