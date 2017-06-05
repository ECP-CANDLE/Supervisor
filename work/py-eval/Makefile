
# Edit Python settings here
# PYTHON_HOME = ${HOME}/sfw/Python-2.7.10
# PYTHON_VERSION_MAJOR = 2
# PYTHON_VERSION_MINOR = 7
# PYTHON_VERSION_SUFFIX =

PYTHON_HOME = ${HOME}/sfw/Python-3.6.1
PYTHON_VERSION_MAJOR = 3
PYTHON_VERSION_MINOR = 6
PYTHON_VERSION_SUFFIX = m
# End Python settings

PYTHON_VERSION = $(PYTHON_VERSION_MAJOR).$(PYTHON_VERSION_MINOR)$(PYTHON_VERSION_SUFFIX)
INCLUDES = -I $(PYTHON_HOME)/include/python$(PYTHON_VERSION)
LIBS     = -L $(PYTHON_HOME)/lib -lpython$(PYTHON_VERSION)
RPATHS   = -Wl,-rpath -Wl,$(PYTHON_HOME)/lib

CFLAGS = -g -Wall -O0 -fPIC -DPYTHON_VERSION_MAJOR=$(PYTHON_VERSION_MAJOR) $(INCLUDES) -fdiagnostics-color=always

SRCS = main.c py-eval.c io.c
OBJS = $(patsubst %.c,%.o,$(SRCS))

all: py-eval

$(OBJS): Makefile # Rebuild everything if Makefile changes

py-eval: $(OBJS)
	gcc -fPIC -o $(@) $(OBJS) \
		$(LIBS) \
		$(RPATHS)

clean:
	@ rm -fv $(OBJS) py-eval
