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
- [ ] Set up the MPI environment (BeeGFS / Lustre + libraries) (write scripts);
- [ ] Implement the MPI solution;
- [ ] Evaluate the MPI solution;

