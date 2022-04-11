#!/usr/bin/env bash
set -e
source ./.env

project_name="$1"
qty="$2"

for i in $(seq 1 $qty)
do
    echo "##### Doing ${i}/${qty}"
    echo "${project_name}-${i}"
    /usr/bin/bash ./scripts/create.sh "${project_name}-${i}"
done