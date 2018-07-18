
# make-package.tcl
# Creates pkgIndex.tcl

set name     eqr
set version  0.1
set leaf_so  libeqr.so

puts [ ::pkg::create -name $name -version $version \
           -load $leaf_so ]
