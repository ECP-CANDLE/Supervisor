#!/bin/bash
set -eu

# CORI BUILD
# Compiles and installs the EQ/R module

THIS=$( dirname $0 )
P1B3_MLRMBO=$( cd $THIS/../../.. ; /bin/pwd )

source $THIS/cori_build_settings.sh
module load swig

cd $THIS
./bootstrap
./configure # The default prefix is the parent directory
make
make install

echo
echo "Successfully installed EQ/R."
