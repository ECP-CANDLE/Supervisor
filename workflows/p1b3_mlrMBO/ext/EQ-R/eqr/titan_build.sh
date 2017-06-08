#!/bin/bash -l
set -eu

# CORI BUILD
# Compiles and installs the EQ/R module

THIS=$( dirname $0 )
P1B3_MLRMBO=$( cd $THIS/../../.. ; /bin/pwd )

source $THIS/titan_build_settings.sh

# Access SWIG and recent Autotools
PATH=/ccs/home/wozniak/Public/sfw/swig-3.0.2/bin:$PATH
module load autoconf/2.69

cd $THIS
./bootstrap
./configure # The default prefix is the parent directory
make
make install

echo
echo "Successfully installed EQ/R."
