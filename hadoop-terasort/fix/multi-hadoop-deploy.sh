#!/bin/bash

hosts=("ip-172-31-2-111")

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4
export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop

host=$(hostname)
master=${hosts[0]}

if [ "$host" == "$master" ]
then
    $HADOOP_PREFIX/bin/hdfs namenode -format teracluster
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
fi

$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode

if [ "$host" == "$master" ]
then
    $HADOOP_PREFIX/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
fi

$HADOOP_PREFIX/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager

