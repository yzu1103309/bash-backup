#!/bin/bash

echo
echo
echo

echo HTTP Requests
echo -------------
echo
echo
printf "%b%-23s %b%-15s  %b%-8s %-8s %b%-40s%b\n" "\e[1;33m" "TIME STAMP" "\e[1;33m" "REQUEST IP" "\e[1;33m" "TYPE" "CODE" "\e[1;36m" "ACCESS HISTORY" "\e[1;37m"
echo
tail -f /opt/lampp/logs/access_log | grep --line-buffered "GET\|POST" | awk -W interactive '{printf "%s %s] %s%s %s %s\n", $1, $4, $6, "\"", $7, $9}' | awk -W interactive '{printf "\033[0;32m%-23s\033[1;37m %-15s  %-8s %-8s %-40s\n", $2, $1, $3, $5, $4}'

