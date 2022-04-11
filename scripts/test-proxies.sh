#!/bin/bash
set -e

echo "Testing proxies"

proxies="./proxies.txt"
while read -r proxy
do
    echo "####################"
    echo "Testing proxy: ${proxy}"
    echo ""

    # curl --socks5 $proxy https://api.ipify.org?format=json
    response=$(curl -s --socks5 $proxy https://api.ipify.org?format=json | jq '.ip')
    echo "Detected IP: ${response}"
    echo "####################"

done < <(tr -d '\r' < $proxies)

