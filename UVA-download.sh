#!/bin/bash

HW="HW11"
Qid=(929 1112 10986 558 10449 10557)

echo -e "#include <iostream>\nusing namespace std;\nint main()\n{\n}" > main.cpp

for i in $(seq 1 ${#Qid[@]})
do
    echo
    echo -e "\e[1;33mDownloading PDF of UVA ${Qid[i-1]} from onlinejudge.com...\e[1;37m"
    wget https://onlinejudge.org/external/$((${Qid[i-1]} / 100))/${Qid[i-1]}.pdf -P ./$HW/uva${Qid[i-1]}/
    echo -e "\e[1;34mCreating template file main.cpp\e[1;37m"
    cp -v main.cpp ./$HW/uva${Qid[i-1]}/
    echo
done

echo
echo -e "\e[1;34mCleaning tmp files...\e[1;37m"
rm -v main.cpp
echo
