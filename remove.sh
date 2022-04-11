#!/usr/bin/env bash
set -e

export "$(grep -vE "^(#.*|\s*)$" .env)"

project_name="$1"
qty="$2"

for i in $(seq 1 $qty)
do
    echo "##### Doing ${i}/${qty}"
   /usr/bin/bash ./destroy.sh "${project_name}-${i}"
done