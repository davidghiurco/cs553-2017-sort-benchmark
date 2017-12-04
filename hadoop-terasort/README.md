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
3. Setup password-less SSH between all relevant hosts from above
4. Depending on which cluster you are configuring, run the following commands

    Single-node cluster:
    ```bash
    cd hadoop-terasort/scripts
    make single-hadoop-setup
    make single-hadoop-deploy
    ```

    Multi-node cluster:
    ```bash
    cd hadoop-terasort/scripts
    make multi-hadoop-setup
    make multi-hadoop-deploy
    ```

    Regardless of which deployment you chose, the scripts will create a source-able BASH script which contains environment
    variable setups for the Hadoop ecosystem

5. Update your $PATH environment with the relevant paths
    ```bash
    source hadoop-prefix.sh
    ```

6. Verify ecosystem has been successfully deployed

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

### Virtual Cluster (1-node i3.large)

1. Create the dataset

### Virtual Cluster (1-node i3.4xlarge)






