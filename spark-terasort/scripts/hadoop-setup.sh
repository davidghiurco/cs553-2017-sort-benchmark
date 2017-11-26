#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4

master="null"

if [ ! -d "download" ]
then
    mkdir download
fi

if [ ! -e "download/hadoop-2.7.4.tar.gz" ]
then
    cd download
    wget http://apache.claz.org/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
    cd ..
fi

if [ ! -d "download/hadoop-2.7.4" ]
then
    cd download
    tar xvf hadoop-2.7.4.tar.gz
    cd ..
fi

sudo apt update
sudo apt install -y openjdk-8-jdk openjdk-8-jre

exists=$(cat ~/.bashrc | grep "JAVA_HOME" | wc -l)
if [ $exists -eq 0 ]
then
    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> ~/.bashrc
fi

exists=$(cat ~/.bashrc | grep "HADOOP_PREFIX" | wc -l)
if [ $exists -eq 0 ]
then
    echo "export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4" >> ~/.bashrc
fi

head -n 24 $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh > temp.txt
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> temp.txt
echo "export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4" >> temp.txt
head -n -25 $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh >> temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh


if [ ! -d "HDFS" ]
then
    mkdir -p HDFS/namenode
    mkdir -p HDFS/datanode
    mkdir -p HDFS/nodemanlocal
    mkdir -p HDFS/nodemanlog
fi

while read line
do
    if [ "$master" == "null" ]
    then
        master=$line
        echo "$line" > $HADOOP_PREFIX/etc/hadoop/slaves
    else
        echo "$line" >> $HADOOP_PREFIX/etc/hadoop/slaves
    fi
done < hadoop-config.cfg

num=$(cat $HADOOP_PREFIX/etc/hadoop/core-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_PREFIX/etc/hadoop/core-site.xml > temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "<configuration>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "        <name>fs.defaultFS</name>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "        <value>hdfs://$master:11155</value>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "        <name>io.file.buffer.size</name>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "        <value>131072</value>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "</configuration>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml

num=$(cat $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml > temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "<configuration>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.namenode.name.dir</name>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <value>$(pwd)/HDFS/namenode</value>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.replication</name>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <value>1</value>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.blocksize</name>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <value>268435456</value>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.datanode.data.dir</name>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <value>$(pwd)/HDFS/datanode</value>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "</configuration>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

num=$(cat $HADOOP_PREFIX/etc/hadoop/yarn-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_PREFIX/etc/hadoop/yarn-site.xml > temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "<configuration>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <name>yarn.resourcemanager.hostname</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <value>$master</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.local-dirs</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <value>$(pwd)/HDFS/nodemanlocal</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.log-dirs</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <value>$(pwd)/HDFS/nodemanlog</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.aux-services</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <value>mapreduce_shuffle</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "</configuration>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

num=$(cat $HADOOP_PREFIX/etc/hadoop/mapred-site.xml.template | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_PREFIX/etc/hadoop/mapred-site.xml.template > temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
echo "<configuration>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.framework.name</name>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
echo "        <value>yarn</value>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
echo "</configuration>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml

