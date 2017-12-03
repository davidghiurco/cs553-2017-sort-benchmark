#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_PREFIX=$(pwd)/download/hadoop-2.7.4

master=$(head -n 1 hadoop-config.cfg)

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
sudo apt install -y openjdk-8-jdk

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

rm -rf HDFS/

if [ ! -d "HDFS" ]
then
    mkdir -p HDFS/namenode
    mkdir -p HDFS/datanode
    mkdir -p HDFS/nodemanlocal
    mkdir -p HDFS/nodemanlog
fi

num=$(cat $HADOOP_PREFIX/etc/hadoop/core-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_PREFIX/etc/hadoop/core-site.xml > temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "<configuration>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "        <name>fs.defaultFS</name>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "        <value>hdfs://$master:9000</value>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
echo "</configuration>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml

num=$(cat $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml > temp.txt
cat temp.txt > $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "<configuration>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.replication</name>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <value>1</value>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.namenode.name.dir</name>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
echo "        <value>$(pwd)/HDFS/namenode</value>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
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
echo "        <name>yarn.nodemanager.aux-services</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "        <value>mapreduce_shuffle</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <value>org.apache.hadoop.mapred.ShuffleHandler</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <name>yarn.resourcemanager.hostname</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <value>$master</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <name>yarn.resourcemanager.resource-tracker.address</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <value>$master:8025</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <name>yarn.resourcemanager.scheduler.address</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <value>$master:8030</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <name>yarn.resourcemanager.address</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <value>$master:8050</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    <property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <name>yarn.nodemanager.resource.cpu-vcores</name>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "        <value>4</value>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
#echo "    </property>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
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

echo "export HADOOP_HOME=$HADOOP_PREFIX" > hadoop_prefix.sh
echo "export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop" >> hadoop-prefix.sh
echo "export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop" >> hadoop-prefix.sh
echo "export PATH=$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:$PATH" >> hadoop-prefix.sh

