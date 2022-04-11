#!/usr/bin/env bash
set -e

PROJECT_NAME="$1"
ecs-cli ps --cluster-config ${PROJECT_NAME} --desired-status RUNNING | awk 'NR>1 {print $3}'  | awk -F '-' '{print $1}' > proxies.txt
