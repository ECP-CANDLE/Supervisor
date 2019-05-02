
all: csv2f64

CC = gcc
CFLAGS = -g -Wall # -O3

PROGRAMS = csv2f64 f64_2csv

csv2f64: csv2f64.o
	$(CC) -o $(@) $(<)

clean:
	rm -fv $(PROGRAMS) *.o
