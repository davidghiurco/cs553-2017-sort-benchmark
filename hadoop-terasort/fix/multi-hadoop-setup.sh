#!/bin/bash

hosts=("ip-172-31-2-111")

dpkg -s openjdk-8-jdk &> /dev/null
if [ $? -eq 1 ]
then
    sudo apt update
    sudo apt install -y openjdk-8-jdk maven build-essential autoconf 
    sudo apt install -y automake libtool cmake zlib1g-dev pkg-config 
    sudo apt install -y protobuf-compiler
fi

exists=$(cat ~/.bashrc | grep "JAVA_HOME" | wc -l)
if [ $exists -eq 0 ]
then
    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> ~/.bashrc
fi

exists=$(cat ~/.bashrc | grep "HADOOP_HOME" | wc -l)
if [ $exists -eq 0 ]
then
    echo "export HADOOP_HOME=$(pwd)/download/hadoop-2.7.4" >> ~/.bashrc
fi

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_HOME=$(pwd)/download/hadoop-2.7.4

host=$(hostname)
master=${hosts[0]}

if [ ! -d "download" ]
then
    mkdir download
fi

if [ ! -e "download/hadoop-2.7.4.tar.gz" ]
then
    cd download
    wget http://apache.mirrors.lucidnetworks.net/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
    cd ..
fi

if [ ! -d "download/hadoop-2.7.4" ]
then
    cd download
    tar xvf hadoop-2.7.4.tar.gz
    cd ..
fi

head -n 24 $HADOOP_HOME/etc/hadoop/hadoop-env.sh > temp.txt
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> temp.txt
echo "export HADOOP_HOME=$(pwd)/download/hadoop-2.7.4" >> temp.txt
tail -n +27 $HADOOP_HOME/etc/hadoop/hadoop-env.sh >> temp.txt
cat temp.txt > $HADOOP_HOME/etc/hadoop/hadoop-env.sh

num=$(cat $HADOOP_HOME/etc/hadoop/core-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_HOME/etc/hadoop/core-site.xml > temp.txt
cat temp.txt > $HADOOP_HOME/etc/hadoop/core-site.xml
echo "<configuration>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "        <name>fs.defaultFS</name>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "        <value>hdfs://$master:9000</value>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "        <name>hadoop.tmp.dir</name>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "        <value>$(pwd)/HDFS/tmp</value>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
echo "</configuration>" >> $HADOOP_HOME/etc/hadoop/core-site.xml

if [ ! -d "HDFS" ]
then
    mkdir -p HDFS/namenode
    mkdir -p HDFS/datanode
    mkdir -p HDFS/nodemanlocal
    mkdir -p HDFS/nodemanlog
fi

num=$(cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_HOME/etc/hadoop/hdfs-site.xml > temp.txt
cat temp.txt > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "<configuration>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.namenode.name.dir</name>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "        <value>$(pwd)/HDFS/namenode</value>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.replication</name>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "        <value>1</value>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "        <name>dfs.datanode.data.dir</name>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "        <value>$(pwd)/HDFS/datanode</value>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo "</configuration>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml

num=$(cat $HADOOP_HOME/etc/hadoop/yarn-site.xml | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_HOME/etc/hadoop/yarn-site.xml > temp.txt
cat temp.txt > $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "<configuration>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <name>yarn.resourcemanager.hostname</name>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <value>$master</value>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.local-dirs</name>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <value>$(pwd)/HDFS/nodemanlocal</value>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.log-dirs</name>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <value>$(pwd)/HDFS/nodemanlog</value>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.aux-services</name>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "        <value>mapreduce_shuffle</value>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.log-aggregation-enable</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>true</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.scheduler.minimum-allocation-vcores</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>1</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.scheduler.maximum-allocation-vcores</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>4</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.resource.cpu-vcores</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>1</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.scheduler.minimum-allocation-mb</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>1024</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.scheduler.maximum-allocation-mb</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>14336</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.resource.memory-mb</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>10240</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>98.5</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    <property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <name>yarn.scheduler.capacity.maximum-am-resource-percent</name>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "        <value>98.5</value>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "    </property>" >> ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
echo "</configuration>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml

num=$(cat $HADOOP_HOME/etc/hadoop/mapred-site.xml.template | grep -n "<configuration>" | cut -d ':' -f1)
head -n $(($num - 1)) $HADOOP_HOME/etc/hadoop/mapred-site.xml.template > temp.txt
cat temp.txt > $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "<configuration>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.framework.name</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>yarn</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.fileoutputcommitter.marksuccessfuljobs</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>false</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.map.memory.mb</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>4096</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.map.java.opts</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>-Xmx3072M</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "        <name>mapreduce.map.cpu.vcores</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "        <value>1</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.reduce.memory.mb</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>4096</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.reduce.java.opts</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>-Xmx3072M</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "        <name>mapreduce.reduce.cpu.vcores</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "        <value>1</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
#echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.task.io.sort.mb</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>1024</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    <property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <name>mapreduce.map.sort.spill.percent</name>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "        <value>0.9</value>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "    </property>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo "</configuration>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml

echo "export HADOOP_HOME=$HADOOP_HOME" > HADOOP_HOME.sh
echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> HADOOP_HOME.sh
echo "export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> HADOOP_HOME.sh
echo "export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH" >> HADOOP_HOME.sh

echo -n "" > $HADOOP_HOME/etc/hadoop/slaves
for i in ${!hosts[@]}
do
    echo "${hosts[$i]}" >> $HADOOP_HOME/etc/hadoop/slaves
done
