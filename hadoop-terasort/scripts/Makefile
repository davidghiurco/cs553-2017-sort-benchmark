BASH=bash

all: hadoop-setup

single-hadoop-setup-large:
	$(BASH) single-hadoop-setup-large.sh

single-hadoop-setup-xlarge:
	$(BASH) single-hadoop-setup-xlarge.sh

single-hadoop-deploy:
	$(BASH) single-hadoop-deploy.sh

multi-hadoop-setup:
	$(BASH) multi-hadoop-setup.sh

multi-hadoop-deploy:
	$(BASH) multi-hadoop-deploy.sh

clean:
	$(RM) -rf download HDFS temp.txt
