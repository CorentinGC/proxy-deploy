#!/usr/bin/env bash
set -e
source setenv.sh

PROJECT_NAME="$1"
QUANTITY="$2"

./scripts/create_cluster.sh "$PROJECT_NAME" 
./scripts/deploy_services.sh "$PROJECT_NAME" "$QUANTITY"
