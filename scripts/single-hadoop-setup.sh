#!/bin/bash

sudo apt-get update
sudo apt-get install openjdk-8-jdk -y

export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"

ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
RSA_PUB=$(cat ~/.ssh/id_rsa.pub)

grep -q "$RSA_PUB" ~/.ssh/authorized_keys
if [ ! $? -eq 0 ]; then
	echo ${RSA_PUB} >> ~/.ssh/authorized_keys
	chmod 0600 ~/.ssh/authorized_keys
fi

if [ ! -d "hadoop" ]; then
	wget http://apache.claz.org/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz
	tar xzf hadoop-2.9.0.tar.gz && mv hadoop-2.9.0 hadoop
	mv hadoop-2.9.0.tar.gz hadoop/ 	 
fi

PWD=$(pwd)
export PATH=${PWD}/hadoop/bin:$PATH

cp config/1node/etc/hadoop/* hadoop/etc/hadoop/
