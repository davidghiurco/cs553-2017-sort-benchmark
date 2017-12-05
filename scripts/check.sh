#!/bin/bash

i=0
echo -n "" > all.sum
while IFS= read line
do
    ./download/64/valsort -o sum$i.dat $line
    cat sum$i.dat >> all.sum
    i=$(($i + 1))
done < res.txt

./download/64/valsort -s all.sum
