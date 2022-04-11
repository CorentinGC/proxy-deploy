#!/usr/bin/env bash
set -e
source setenv.sh

PROJECT_NAME="$1"

echo $PROJECT_NAME
echo $QUANTITY

DOCKER_COMPOSE_INPUT="./clusters/docker-compose.${PROJECT_NAME}.yml"
ECS_PARAMS_INPUT="./clusters/ecs-params.${PROJECT_NAME}.yml"

echo "Create cluster ${PROJECT_NAME} on ${AWS_REGION}"

# Generate compose file
python3 ./scripts/config_compose.py ${PROJECT_NAME}

# ECS CLI configuration
# cluster config
echo "create ecs cluster config"
ecs-cli configure --cluster ${PROJECT_NAME} --config-name ${PROJECT_NAME} --region ${AWS_REGION} --default-launch-type FARGATE

# deploy cluster
echo "ecs-cli up running"
result=$(ecs-cli up --force --ecs-profile "${AWS_PROFILE}" --cluster-config "${PROJECT_NAME}" 2>&1 | tee /dev/tty)
echo "ecs-cli up done"
vpc_id=$(echo "$result" | grep -o "VPC created: .*" | cut -f2 -d ":" | xargs)
echo "vpc_id=${vpc_id}"
subnet_ids=$(echo "$result" | grep -o "Subnet created: .*" | cut -f2 -d ":" | xargs)
echo "subnet_ids=${subnet_ids}"
security_grp_id=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=${vpc_id} --region ${AWS_REGION} | jq '.SecurityGroups | .[0] | .GroupId' | tr -d '"')
echo "security_grp_id=${security_grp_id}"

# remove all rules
aws ec2 revoke-security-group-ingress --profile $AWS_PROFILE --group-id $security_grp_id --ip-permissions $("aws ec2 describe-security-groups --profile ${AWS_PROFILE} --output json --group-ids ${security_grp_id} --query 'SecurityGroups[0].IpPermissions'")
# add allowed ip:port to rules
aws ec2 authorize-security-group-ingress --profile $AWS_PROFILE --group-id $security_grp_id --port ${ALLOWED_PORT} --cidr "${ALLOWED_IP}/32" --protocol "tcp"

# use an array
array=(${subnet_ids//,/ })
subnet_a=${array[0]}
subnet_b=${array[1]}

# call the python script with the arguments passed
python3 ./scripts/set_ecs_params.py "${vpc_id}" "${security_grp_id}" "${subnet_a}" "${subnet_b}" "${PROJECT_NAME}" "${QTY}"

# ecs-cli configure --cluster test --config-name test --region eu-west-1 --default-launch-type FARGATE

# ecs-cli up --force --ecs-profile default --cluster-config test