
# MAKE PACKAGE TCL
# Creates pkgIndex.tcl

set name     horovod
set version  0.0
set leaf_tcl horovod.tcl
set leaf_so  libtclhorovod.so

puts [ ::pkg::create -name $name -version $version \
           -load $leaf_so \
           -source $leaf_tcl ]
