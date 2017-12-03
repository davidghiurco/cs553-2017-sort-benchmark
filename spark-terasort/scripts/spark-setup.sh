#!/usr/bin/env bash

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
# export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4

master="null"

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

sudo apt update
sudo apt install -y openjdk-8-jdk openjdk-8-jre
sudo apt install -y scala

# wget http://www.scala-lang.org/files/archive/scala-2.10.6.tgz
# sudo mkdir /usr/local/src/scala
# sudo tar xvf scala-2.10.6.tgz -C /usr/local/src/scala/


export SPARK_HOME=$(pwd)/download/spark-2.2.0-bin-hadoop2.7
export PATH=${SPARK_HOME}/bin:$PATH

echo "export SPARK_HOME=$SPARK_HOME" > spark_prefix.sh
echo "export PATH=${SPARK_HOME}/bin:$PATH" >> spark_prefix.sh
