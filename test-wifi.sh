#!/bin/bash

count=1

while true
do
    echo
    echo -e "\e[1;33m[第 $count 次自動測試]\e[1;37m"
    echo
    iw dev wlo1 link | grep --color=auto "SSID\|signal\|tx bitrate"
    echo
    read -t 3
    count=$((count+1))
done
