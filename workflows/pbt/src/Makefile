CC = mpicc
LD = mpicc

# Cori
#CC = cc
#LD = cc

CFLAGS = -Wall -O0 -g3 -MMD -MP -fPIC

DATASPACES = $(HOME)/sfw/dataspaces-1.6.5
#DATASPACES=/project/projectdirs/m2924/ncollier/sfw/dataspaces-1.6.5

DS_C = $(DATASPACES)/bin/dspaces_config
DSPACES_INC=$(shell $(DS_C) -c)
DSPACES_LIB=$(shell $(DS_C) -l)

CFLAGS += $(DSPACES_INC)
LDFLAGS = $(DSPACES_LIB) -Wl,-rpath -Wl,$(DATASPACES)/lib
#LDFLAGS = -L$(DATASPACES)/lib -Wl,-whole-archive  $(DATASPACES)/lib/libdspaces.a  $(DATASPACES)/lib/libdscommon.a  $(DATASPACES)/lib/libdart.a -Wl,-no-whole-archive

LIB_NAME = libpbt_ds.so

all: libpbt

libpbt : pbt_ds.o
	$(LD) -shared $^ $(LDFLAGS) -o $(LIB_NAME)
	cp libpbt_ds.so ../python

src/%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -fv *.o $(LIB_NAME)
