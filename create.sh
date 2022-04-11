#!/usr/bin/env bash
set -e

ALLOWED_IP="82.64.99.94"
ALLOWED_PORT="1337"

PROJECT_NAME="$1"
CLEAN_PROJECT_NAME=$(echo ${1} | awk -F '-' '{print $1}')

DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${CLEAN_PROJECT_NAME}.yml"
ECS_PARAMS_INPUT="./clusters/ecs-params.${PROJECT_NAME}.yml"

echo "Deploying ${PROJECT_NAME}"
# Generate compose file
python3 ./config_compose.py ${CLEAN_PROJECT_NAME}

# ECS CLI configuration
# create ecs cluster config
echo "create ecs cluster config"
ecs-cli configure --cluster ${PROJECT_NAME} --config-name ${PROJECT_NAME} --region ${AWS_REGION} --default-launch-type FARGATE

# ecs-cli up
echo "ecs-cli up running"
result=$(ecs-cli up --force -ecs-profile default --cluster-config ${PROJECT_NAME})
echo "ecs-cli up done"
vpc_id=$(echo "$result" | grep -o "VPC created: .*" | cut -f2 -d ":" | xargs)
echo "vpc_id=${vpc_id}"

subnet_ids=$(echo "$result" | grep -o "Subnet created: .*" | cut -f2 -d ":" | xargs)
echo "subnet_ids=${subnet_ids}"

security_grp_id=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=${vpc_id} --region ${AWS_REGION} | jq '.SecurityGroups | .[0] | .GroupId' | tr -d '"')
echo "security_grp_id=${security_grp_id}"

# remove all rules
aws ec2 revoke-security-group-ingress --profile default --group-id $security_grp_id \
  --ip-permissions \
  "`aws ec2 describe-security-groups --profile default --output json --group-ids $security_grp_id --query "SecurityGroups[0].IpPermissions"`"

## add allowed ip to rules
aws ec2 authorize-security-group-ingress --profile $AWS_PROFILE --group-id $security_grp_id --port "${ALLOWED_PORT}" --cidr "${ALLOWED_IP}/32" --protocol "tcp"

# use an array
array=(${subnet_ids//,/ })
subnet_a=${array[0]}
subnet_b=${array[1]}

# call the python script with the arguments passed
python3 ./set_ecs_params.py "${vpc_id}" "${security_grp_id}" "${subnet_a}" "${subnet_b}" "${PROJECT_NAME}"

# deploy to the ecs cluster
ecs-cli compose --project-name $PROJECT_NAME --file $DOCKER_COMPOSE_INPUT --ecs-params $ECS_PARAMS_INPUT --debug service up --region $AWS_REGION --ecs-profile $AWS_PROFILE --cluster-config $PROJECT_NAME

data=$(ecs-cli ps --cluster-config ${PROJECT_NAME} | awk 'NR==2{print $3}' | awk -F '-' '{print $1}')
ip=$(echo $data | awk -F ':' '{print $1}')
port=$(echo $data | awk -F ':' '{print $2}')
echo "Container deployed"
echo "IP: ${ip}"
echo "PORT: ${port}"

echo "${data}" >> proxies.txt
