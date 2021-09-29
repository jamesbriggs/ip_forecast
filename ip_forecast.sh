#!/bin/bash

# Program: ip_forecast.sh
# Purpose: show weather forecast for a location using an IP address, demonstrating curl and jq
# Author: James Briggs
# Date: 2021 02 08
# Env: bash
# Usage: ip_forecast.sh [IP]
# Note:

ip=$1

os_linux=1

if grep -q "apple" <<< "$MACHTYPE"; then
   os_linux=0
fi

info=`curl -s -o - https://ipinfo.io/$ip`

loc=`echo $info | jq -r '.loc'`
city=`echo $info | jq -r '.city'`
if [[ "$ip" == "" ]]; then
   ip=`echo $info | jq -r '.ip'`
fi

echo "Weather forecast for $ip ($city):"

out=`curl -s -o - https://api.darksky.net/forecast/6ce2cb95ebf7afee7f2d76afcc037fb3/$loc`

today=`date +'%Y-%m-%d'`

n=0
echo $out | jq -r '.daily.data[] | [ .time, .summary ] | @tsv' |
  while IFS=$'\t' read -r t s; do
      if [[ "$os_linux" == 1 ]]; then
         dt=`date -d @$t +'%Y-%m-%d'`
      else
         dt=`date -r $t +'%Y-%m-%d'`
      fi

      if [[ "$dt" > "$today" ]]; then
         if [[ $n < 3 ]]; then
            echo "$dt: $s"
            let n=n+1
         fi
      fi
  done

exit 0
