BASH=bash

all: setup data

setup: gen-setup.sh
	$(BASH) gen-setup.sh

data: gen-data.sh
	$(BASH) gen-data.sh

clean:
	$(RM) -rf download data
