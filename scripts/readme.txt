These scripts set up the generator and generate the data sets used by the
sorting applications. In order to quickly download and run the generator, a
Makefile has been provided, and the make targets are:

* download the generator and generate the data sets:
make all

* download the generator:
make setup

* generate the data sets:
make data

* remove the data and the generator (clean):
make clean

+ A script has been provided, that validates the output of the shared memory
implementation, namely "check.sh", that requires the existence of a file
"res.txt", in the same directory, containing the output files listed by the
application, in that precise order. With the file properly provided 'bash
check.sh' should validate the results.
