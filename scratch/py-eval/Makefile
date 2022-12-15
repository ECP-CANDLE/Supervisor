
# PY EVAL MAKEFILE

# MPI_ENABLED = 1
MPI_ENABLED = 0

# Edit Python settings here

# PYTHON_HOME = ${HOME}/sfw/Python-2.7.10
# PYTHON_VERSION_MAJOR = 2
# PYTHON_VERSION_MINOR = 7
# PYTHON_VERSION_SUFFIX =

# PYTHON_HOME = ${HOME}/sfw/Python-3.6.1
# Titan:
# PYTHON_HOME = /sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3
# PYTHON_VERSION_MAJOR = 3
# PYTHON_VERSION_MINOR = 6
# PYTHON_VERSION_SUFFIX = m

# Cori
# Module tensorflow/intel-head
# PYTHON_HOME = /usr/common/software/tensorflow/intel-tensorflow/head
# PYTHON_VERSION_MAJOR = 2
# PYTHON_VERSION_MINOR = 7
# PYTHON_VERSION_SUFFIX =
# CC = gcc # module load gcc

CC = gcc

# Dunedin 3.8 Spack
PYTHON_HOME = /usr
PYTHON_VERSION_MAJOR = 3
PYTHON_VERSION_MINOR = 8
PYTHON_VERSION_SUFFIX =

# Dunedin 3.7.3 TF
# PYTHON_HOME = ${HOME}/Public/sfw/Python-3.7.3-tf
# PYTHON_VERSION_MAJOR = 3
# PYTHON_VERSION_MINOR = 7
# PYTHON_VERSION_SUFFIX = m

# Dunedin 2.7
# PYTHON_HOME = /usr
# PYTHON_VERSION_MAJOR = 2
# PYTHON_VERSION_MINOR = 7
# PYTHON_VERSION_SUFFIX =


# End Python settings

PYTHON_VERSION = $(PYTHON_VERSION_MAJOR).$(PYTHON_VERSION_MINOR)$(PYTHON_VERSION_SUFFIX)
INCLUDES = -I $(PYTHON_HOME)/include/python$(PYTHON_VERSION)
# LIBS     = -L $(PYTHON_HOME)/lib
LIBS     += -lpython$(PYTHON_VERSION) -ldl
RPATHS   = -Wl,-rpath -Wl,$(PYTHON_HOME)/lib

DEFINES = -DPYTHON_VERSION_MAJOR=$(PYTHON_VERSION_MAJOR) \
	  -DMPI_ENABLED=$(MPI_ENABLED)

CFLAGS = -g -Wall -O0 -fPIC $(DEFINES) $(INCLUDES) -fdiagnostics-color=always

# Compilation units
UNITS   = py-eval io util
HEADERS = $(patsubst %,%.h,$(UNITS))
SRCS    = main.c $(patsubst %,%.c,$(UNITS))
OBJS    = $(patsubst %.c,%.o,$(SRCS))

all: py-eval

# Rebuild everything if Makefile or headers change
$(OBJS): Makefile $(HEADERS)

py-eval: $(OBJS)
	$(CC) -fPIC -o $(@) $(OBJS) \
		$(LIBS) \
		$(RPATHS)

clean:
	@ rm -fv $(OBJS) py-eval
