#!/bin/bash

file=($(ls *.heic))

for((i=0; i<${#file[@]}; ++i))
do
    heif-convert -q 100 ${file[$i]} ${file[$i]}.png
done
