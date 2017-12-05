CC=gcc
CFLAGS=-g -Wall
LIBS=-lpthread

all:
	mkdir -p bin
	$(CC) $(CFLAGS) -o bin/pterasort.exe src/pterasort.c $(LIBS)

clean:
	$(RM) bin/*.exe
