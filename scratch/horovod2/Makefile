
# USER SETTINGS START
# Change these for your system
# Your mpicc:
CC             = mpicc
# This directory (the top level of Horovod)
# HOROVOD        = ${HOME}/proj/horovod
# PYTHON_VERSION = 2.7
# PYTHON_INCLUDE = /usr/include/python$(PYTHON_VERSION)
# PYTHON_LIB     = /usr/lib/python$(PYTHON_VERSION)/config-x86_64-linux-gnu
PYTHON_VERSION = 3.7m
PY = ${HOME}/Public/sfw/Python-3.7.3-tf
PYTHON_INCLUDE = $(PY)/include/python$(PYTHON_VERSION)
PYTHON_LIB     = $(PY)/lib
# USER SETTINGS END

# CONTROLLER     = $(HOROVOD)/controller

INCLUDES = -I $(PYTHON_INCLUDE) # -I $(CONTROLLER)

CPPFLAGS = $(INCLUDES)
CFLAGS = -Wall -fPIC -fmax-errors=1

# INCLUDE_CONTROLLER = -I$(CONTROLLER)

LIBS = -L $(PYTHON_LIB) -l python$(PYTHON_VERSION)


# CC  = mpicc
# CXX = mpicxx

all: test-0.x test-1.x test-2.x test-3.x test-4.x test-5.x

test-%.x: test-%.o controller.o slurp.o
	$(CC) -o $(@) $(^) $(LIBS) -l dl

test-%.o: Makefile

clean:
	rm -fv *.x *.o

.PRECIOUS: %.o
