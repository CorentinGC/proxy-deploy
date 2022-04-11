#!/usr/bin/env bash
set -e
source setenv.sh

PROJECT_NAME="$1"
QUANTITY="$2"

./down.sh $PROJECT_NAME $QUANTITY
./up.sh $PROJECT_NAME $QUANTITY
