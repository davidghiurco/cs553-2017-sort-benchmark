The Spark implementation of the TeraSort problem is organized in the source
files and a set of configuration and deployment scripts. The Apache Spark
framework uses libraries and interfaces part of Hadoop, in order to communicate
with HDFS and YARN. Thus the deployment of Spark requires the Hadoop ecosystem
to also be deployed.

1. Setup Hadoop (use the deployment in the hadoop-terasort module)

2. Generate dataset using gensort

3. Move dataset to HDFS

4. Delete dataset on local file (to save space)

5. Make sure the HDFS directory "output" does not exist
```bash
hadoop fs -rm -r -f /output
```
5. Run the STerasort application

From the project root:
```bash
source spark-terasort/scripts/spark-prefix.sh
spark-submit --master yarn --deploy-mode cluster spark-terasort/build/libs/stera.jar (num_partitions)

```

Where (num_partitions) is the number of parallel partitions in Spark's RDD.
Generally, this should be set to the number of cores available:
For i3.large: num_partitions = 2
For i3.xlarge: num_partitions = 16
For 8x i3.large: num_partitions = 16

6. Delete the input directory in HDFS, and copy the output directory to the local filesystem

```bash
hadoop fs -rm -r -f /input
hadoop fs -copyToLocal /output .
```

7. Run the valsort validator on the files found in ./output to verify sort completed successfully
