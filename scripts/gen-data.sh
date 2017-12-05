#!/bin/bash

if [ ! -d "data" ]
then
    mkdir data
fi

./download/64/gensort -a 1280000000 data/small.data
#./download/64/gensort -a 10000000000 data/big.data
