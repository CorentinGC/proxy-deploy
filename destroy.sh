#!/usr/bin/env bash
project_name="$1"

# cleanup aws log group
# aws logs delete-log-group --log-group-name $project_name

docker_compose_input="./clusters/docker-compose.${project_name}.yml"
ecs_params_input="./clusters/ecs-params.${project_name}.yml"

# # clean up ecs cluster
ecs-cli compose --file $docker_compose_input --ecs-params $ecs_params_input --project-name $project_name service down --cluster-config $project_name
ecs-cli down --force --cluster-config $project_name

rm $docker_compose_input
rm $ecs_params_input
