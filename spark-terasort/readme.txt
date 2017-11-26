The Spark implementation of the TeraSort problem is organized in the source
files and a set of configuration and deployment scripts. The Apache Spark
framework uses libraries and interfaces part of Hadoop, in order to communicate
with HDFS and YARN. Thus the deployment of Spark requires the Hadoop ecosystem
to also be deployed.

1. Hadoop setup and deployment
All the configuration and deployment files (including the deployment path) are
found in the scripts directory. All the scripts can be called individually, but
for simple usage, one can just run make targets, through the provided Makefile.
Further on, the steps for deploying Hadoop for Spark are discussed:

* For a cluster deployment, the setup and deployment scripts require
  password-less ssh to be enabled. The provided scripts do not set up
  password-less ssh, since it requires intrinsic knowledge of the cluster
  topology and a priori access to public-private keys, thus it needs to e set up
  manually before running any of the scripts.

* The node hostnames, that form the cluster, need to be added to the
  'hadoop-config.cfg' file, the first entry representing both a master and a
  slave node at the same time.

* Run 'make hadoop-setup' to set up the Hadoop sources and xml configuration
  files. This scripts needs to be run from all the nodes that compose the
  cluster. This script is going to install the dependencies (requires sudo
  permissions) ...
