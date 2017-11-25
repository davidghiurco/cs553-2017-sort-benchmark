#!/bin/bash

if [ ! -d "data" ]
then
    mkdir data
fi

./download/64/gensort -a 128000 data/small.data
./download/64/gensort -a 1000000 data/big.data
