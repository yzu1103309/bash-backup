#!/bin/bash

arr=($(ls ./normal))

g++ ./main.cpp -o main `pkg-config --cflags --libs opencv4`

for((i = 0; i < ${#arr[@]}; ++i)); do
    echo ${arr[$i]}
    echo
    rm -v -rf ./output_rgb/${arr[$i]}/Series_005_T2_FLAIR_tra
    echo
    ./main ${arr[$i]}
    echo
done
