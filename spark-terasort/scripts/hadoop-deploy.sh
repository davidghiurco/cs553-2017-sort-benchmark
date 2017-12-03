#!/bin/bash

set -x

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4

HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop

master="null"
while read line
do
    if [ "$master" == "null" ]
    then
        master=$line
        break
    fi
done < hadoop-config.cfg

if [ "$(hostname)" == "$master" ]
then
    $HADOOP_PREFIX/bin/hdfs namenode -format terasortcluster
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
fi

$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
