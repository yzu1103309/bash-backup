#!/bin/bash

curl -H "Authorization: Bearer <auth token>" -H "Ngrok-Version: 2" https://api.ngrok.com/endpoints > public_url.json

echo

echo -e "var URL = '$(cat public_url.json | jq -r '.endpoints[].public_url')/';" > /home/wilson/Documents/Hugo/myBlog/js/url.js

echo -e '\e[1;32mUpdated the url.js file successfully!\e[1;37m'

echo

echo New content:
cat /home/wilson/Documents/Hugo/myBlog/js/url.js

echo

read -p $'\e[0;34mProceed to commit? [y/n]\e[1;37m' yn

case $yn in
    [Yy] )  cd /home/wilson/Documents/Hugo/myBlog/
            git status
            echo
            git commit -a -m "update ngrok url"
            echo
            git push
            echo
            git status
            echo
            ;;

    [Nn] )  echo
            echo Nothing was committed.
            echo
            ;;
    * ) echo
        echo Wrong expression.
        echo
        ;;
esac


read -p $'\e[1;33m[Enter結束程序]\e[1;37m' continue
