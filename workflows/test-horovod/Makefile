
all: pkgIndex.tcl libhorovod.so

horovod_wrap.c: horovod.i
	swig ${CPPFLAGS} $(<)

libhorovod.so: horovod_wrap.o ${CONTROLLER}/controller.o
	mpicc -shared -o $(@) horovod_wrap.o ${CONTROLLER}/controller.o \
		-l python2.7

pkgIndex.tcl: make-package.tcl 
	tclsh make-package.tcl > pkgIndex.tcl

clean:
	rm -fv pkgIndex.tcl *.so *.o horovod_wrap.c
