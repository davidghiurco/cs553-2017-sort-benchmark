BASH=bash

all: hadoop-setup

hadoop-setup: hadoop-setup.sh
	$(BASH) hadoop-setup.sh

hadoop-deploy: hadoop-deploy.sh
	$(BASH) hadoop-deploy.sh

clean:
	$(RM) -rf download HDFS
