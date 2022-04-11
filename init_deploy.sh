#!/usr/bin/env bash
set -e

PROJECT_NAME="$1"
QUANTITY="$2"

echo $AWS_REGION
./scripts/create_cluster.sh "$PROJECT_NAME" 
# /usr/bin/bash ./scripts/deploy_services.sh "$PROJECT_NAME" "$QUANTITY"
