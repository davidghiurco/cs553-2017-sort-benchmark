Note: environment variable $HADOOP_PREFIX needs to be set for this to work

compile:

HADOOP_CLASSPATH=$($HADOOP_PREFIX/bin/hadoop classpath)
rm -rf build/
mkdir build
javac -classpath $HADOOP_CLASSPATH -d build/ src/HTerasort.java
cd build/
jar -cvf ht.jar HTerasort*.class