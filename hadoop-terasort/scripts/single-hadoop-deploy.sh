#!/usr/bin/env bash
set -x

sudo ufw disable

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4

export HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop

${HADOOP_PREFIX}/bin/hdfs namenode -format
${HADOOP_PREFIX}/sbin/start-dfs.sh
${HADOOP_PREFIX}/sbin/start-yarn.sh

