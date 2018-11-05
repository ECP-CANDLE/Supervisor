
CC = mpicc
PYTHON_VERSION = 2.7

INCLUDES = -I /usr/include/python$(PYTHON_VERSION)
CPPFLAGS = $(INCLUDES)
CFLAGS = -Wall -fPIC

all: _fl_interface.so fl_interface.py

_fl_interface.so: fl_interface_wrap.o fl_interface.o fl.o
	$(CC) -shared -o $(@) $(^) -lpython$(PYTHON_VERSION)

fl_interface_wrap.c fl_interface.py: \
	fl_interface.i fl_interface.h Makefile
	swig -python $(<)

clean:
	rm -fv *.so *.o *_wrap.c
