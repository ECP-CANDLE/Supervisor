
CC = gcc

HOROVOD = ${HOME}/proj/horovod
CONTROLLER = $(HOROVOD)/controller
TCL = /usr/include/tcl8.6

INCLUDE_CONTROLLER = -I$(CONTROLLER)

INCLUDES = $(INCLUDE_CONTROLLER) -I$(TCL)

CPPFLAGS = $(INCLUDES)
CFLAGS = -fPIC

LIB_PYTHON = -L /usr/lib/python2.7/config-x86_64-linux-gnu -l python2.7


LINKFLAGS = -L$(CONTROLLER) -l controller \
		$(LIB_PYTHON)

RPATHS = -Wl,-rpath -Wl,$(CONTROLLER)

all: pkgIndex.tcl

horovod_wrap.c: horovod.i $(CONTROLLER)/controller.h Makefile
	swig $(INCLUDE_CONTROLLER) $(<)
	sed -i s/Horovod_Init/Tclhorovod_Init/ $(@)

libtclhorovod.so: horovod_wrap.o
	$(CC) -shared -o $(@) $(<) \
		$(LINKFLAGS) \
		$(RPATHS)

pkgIndex.tcl: make-package.tcl libtclhorovod.so Makefile
	tclsh $(<) > $(@)

clean:
	@rm -fv pkgIndex.tcl *.so *.o horovod_wrap.c
