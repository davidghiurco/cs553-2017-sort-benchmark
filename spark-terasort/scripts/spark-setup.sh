#!/usr/bin/env bash

dpkg -s openjdk-8-jdk >> /dev/null
EXIT_STATUS=$?
if [ ! "$EXIT_STATUS" -eq 0 ]; then
sudo apt update
sudo apt install -y openjdk-8-jdk
sudo apt install -y scala
fi
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

master="flamedragon"

if [ ! -d "download" ]
then
    mkdir download
fi

if [ ! -e "download/spark-2.2.0-bin-hadoop2.7.tgz" ]
then
    cd download
    wget http://apache.mirrors.hoobly.com/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
    cd ..
fi

if [ ! -d "download/spark-2.2.0-bin-hadoop2.7.tgz" ]
then
    cd download
    tar xvf spark-2.2.0-bin-hadoop2.7.tgz
    cd ..
fi


export SPARK_HOME=$(pwd)/download/spark-2.2.0-bin-hadoop2.7
export PATH=${SPARK_HOME}/bin:$PATH

echo "export SPARK_HOME=$SPARK_HOME" > spark-prefix.sh
echo "export PATH=${SPARK_HOME}/bin:$PATH" >> spark-prefix.sh
