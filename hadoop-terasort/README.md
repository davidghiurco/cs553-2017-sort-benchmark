# Hadoop TeraSort

## Compiling & running the application

From the project root:

```bash
cd hadoop-terasort/
../gradlew :hadoop-terasort:build
```
This will install the JAR file in hadoop-terasort/build/libs/htera.jar

## Apache Hadoop and HDFS setup

1. Edit scripts/hadoop-config.cfg. Enter hostnames of the cluster. The cluster master hostname should be the first entry,
and subsequent entries should be the hostnames of slave nodes. In the case of single-node cluster deployment, enter 'localhost'
2. Check that the entries in hadoop-config.cfg are correctly setup with proper addresses in /etc/hosts
3. Setup password-less SSH between all relevant hosts from above. This includes single-node deployments
4. Add the results of $(hostname) to /etc/hosts with the corresponding private DNS address
    Example /etc/hosts (on AWS):
    ```bash
    127.0.0.1 localhost
    172.31.36.148 ip-172-31-36-148
    
    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts

    ```
5. Depending on which cluster you are configuring, run the following commands

    Single-node cluster (1x i3.large):
    ```bash
    cd hadoop-terasort/scripts
    make single-hadoop-setup-large
    make single-hadoop-deploy
    ```
    
    Single-node cluster (1x i3.4xlarge):
    ```bash
    cd hadoop-terasort/scripts
    make single-hadoop-setup-xlarge
    make single-hadoop-deploy
    ```

    Multi-node cluster (8x i3.large):
    ```bash
    cd hadoop-terasort/scripts
    make multi-hadoop-setup
    make multi-hadoop-deploy
    ```
    
    Accept any requests to connect to various IP addresses.

    Regardless of which deployment you chose, the scripts will create a source-able BASH script which contains environment
    variable setups for the Hadoop ecosystem

6. Update your $PATH environment with the relevant paths
    ```bash
    source hadoop-prefix.sh
    ```

7. Verify ecosystem has been successfully deployed

    ```bash
    jps
    ```
    should output something like this:

    ```bash
    29633 Jps
    27928 SecondaryNameNode
    28203 NodeManager
    27709 DataNode
    27583 NameNode
    28079 ResourceManager
    ```

    If you ran a gradle build, you will also see a GradleDaemon process listed by the previous command

## Experiment Setup

NOTE: We used Hadoop TeraGen and TeraValidate instead of gensort and valsort. The distribution for the programs is broken

### Virtual Cluster (1-node i3.large) (128 GB)

1. Create the dataset

    From the project root:
    ```bash
    hadoop jar hadoop-mapreduce-examples.jar teragen 1280000000 /input
    ```
2. Run HTerasort with 2 reduce tasks (for 2 VCPUs):

    ```bash
    hadoop jar hadoop-terasort/build/libs/htera.jar -Dmapred.reduce.tasks=2 /input /output
    ```
3. Run the TeraValidator to check the output is sorted:

    ```bash
    hadoop jar hadoop-mapreduce-examples.jar teravalidate /output /report
    ```
4. Verify the report. If the output is sorted correctly, the only output in the file found in
the /report directory will be the checksum

    ```bash
    hadoop fs -ls /report
    hadoop fs -cat /report/file_name
    ```

### Virtual Cluster (1-node i3.4xlarge) (1 TB)






