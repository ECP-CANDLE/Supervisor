#cc = mpicc
#ld = mpicc

# Cori
cc = cc
ld = cc

CFLAGS = -Wall -O0 -g3 -MMD -MP -fPIC

#DATASPACES = $(HOME)/sfw/dataspaces-1.6.5
DATASPACES=/project/projectdirs/m2924/ncollier/sfw/dataspaces-1.6.5

DS_C = $(DATASPACES)/bin/dspaces_config
DSPACES_INC=$(shell $(DS_C) -c)
DSPACES_LIB=$(shell $(DS_C) -l)

CFLAGS += $(DSPACES_INC)
LDFLAGS = $(DSPACES_LIB) -Wl,-rpath -Wl,$(DATASPACES)/lib
#LDFLAGS = -L$(DATASPACES)/lib -Wl,-whole-archive  $(DATASPACES)/lib/libdspaces.a  $(DATASPACES)/lib/libdscommon.a  $(DATASPACES)/lib/libdart.a -Wl,-no-whole-archive

LIB_NAME = libpbt_ds.so

libpbt : src/pbt_ds.o
	$(ld) -shared $^ $(LDFLAGS) -o $(LIB_NAME)

src/%.o : src/%.c
	$(cc) $(CFLAGS) -c $< -o $@

clean:
	rm -fv src/*.o $(LIB_NAME)
