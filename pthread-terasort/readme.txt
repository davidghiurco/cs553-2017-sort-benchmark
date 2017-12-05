This directory contains the shared memory implementation of the terasort
problem. There is only one source file, written in C that contains all the code.
The source can be compiled through the use of a provided Makefile. Details
regarding the implementation can be found in the report. The application can be
run like this:

./bin/pterasort.exe <input_file_path> <size_in_bytes_of_input_file>

Here is an example:

./bin/pterasort.exe ../scripts/data/small.data 128000000000
