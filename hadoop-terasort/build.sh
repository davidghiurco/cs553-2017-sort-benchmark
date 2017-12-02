#!/usr/bin/env bash
HADOOP_CLASSPATH=$($HADOOP_PREFIX/bin/hadoop classpath)
rm -rf build
mkdir build
javac -classpath ${HADOOP_CLASSPATH} -d build/ src/HTerasort.java
cd build/
jar -cvf ht.jar HTerasort*.class