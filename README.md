# cs553-2017-sort-benchmark #

PA2 for CS 553 @ Illinois Institute of Technology

# Authors

David Ghiurco, Alexandru Iulian Orhean

# Description

This repository contains the solution (source code and configuration scripts)
for the second CS553 programming assignment (2017). The objective of the
assignment is to provide four different implementation for the TeraSort
(external sort of 1 TB of data) problem: shared memory, Hadoop, Spark and MPI;
and study the weak scalability of each solution for three different
configurations:

1. 1-node i3.large Amazon EC2 instance;
2. 1-node i3.4xlarge Amazon EC2 instance;
3. 8-node i3.large Amazon EC2 instances;

Note: MPI TeraSort was not implemented in this report

# Project Organization

The implementation are organized in different directories, that contain the
source code, build scripts and configuration scripts, but also the scripts that
generates the data to be sorted.

# Tasks

The task list for the homework assignment:
- [ ] Implement the shared memory solution;
- [ ] Evaluate the shared memory solution;
- [ ] Set up the Hadoop environment (HDFS + framework) (write scripts);
- [ ] Implement the Hadoop solution;
- [ ] Evaluate the Hadoop solution;
- [ ] Set up the Spark environment (HDFS + framework) (write scripts);
- [ ] Implement the Spark solution;
- [ ] Evaluate the Spark solution;

# Setting up Filesystem storage

Before running any deployment, we need to create a mountpoint for the SSD of the AWS instance.
i3.large nodes have an 8 GB partition allocated to the OS, and 442.4 G unallocated.
i3.4x large nodes need a mountpoint setup with RAID 0 in order to be able to store 1 TB in HDFS

## Setting up 1x i3.large

```bash
lsblk
sudo fdisk /dev/nvme0n1
```
Create a new partition on the disk (n), select primary type (p), accept defaults, and write the partition to disk (w)

Create a mountpoint for the partition
```bash
sudo mkfs.ext4 /dev/nvme0n1p1
sudo mkdir /mnt/storage
sudo mount /dev/nvm10n1p1 /mnt/storage
```

Now, clone this repository into /mnt/storage, and use the deployment scripts. They will assume that the mountpoint the 
repository is cloned to is the disk where the HDFS filesystem will reside. HDFS files will be stored
under the hadoop-terasort module directory.

## Setting up 1x i3.4xlarge


## Setting up 8x i3.large

1. Setup RAID 0

```bash
sudo apt-get install -y mdadm
lsblk
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme1n1
```

2. Format the disk
Note: This will take a VERY long time. Close to 45 minutes. 3.5 TB has to be formatted
```bash
lsblk
sudo mkfs.ext4 /dev/mdo
```



# Building Project

```bash
sudo apt-get update
sudo apt-get install -y make openjdk-8-jdk
./gradlew build
```
This will install Java and Make, then compile the hadoop-terasort & spark-terasort modules

To stop the gradle daemon after compilation (so it doesn't waste memory):
```bash
./gradlew --stop
```

The Hadoop application JAR will be installed in:
```bash
hadoop-terasort/build/libs/htera.jar
```

The Spark application JAR will be installed in:
```bash
spark-terasort/build/libs/stera.jar
```
To setup the ecosystem of each implementation, and for experiment setup instructions, 
see the respective README.md of each module
