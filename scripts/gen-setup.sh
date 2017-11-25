#!/bin/bash

if [ ! -d "download" ]
then
    mkdir download
fi

if [ ! -e "download/gensort-linux-1.5.tar.gz" ]
then
    cd download
    wget http://www.ordinal.com/try.cgi/gensort-linux-1.5.tar.gz
    cd ..
fi

if [ ! -d "download/64" ]
then
    cd download
    tar xvf gensort-linux-1.5.tar.gz
    cd ..
fi

