#!/bin/sh
set -eu

# INSTALL CANDLE R

# Installs all R packages needed for Supervisor workflows

echo "This will install multiple R packages for CANDLE."
echo
echo "using R:        $( which R )"
echo "using gcc:      $( which gcc )"
echo "using gfortran: $( which gfortran )"
echo
sleep 1
echo "Press enter to confirm, or Ctrl-C to cancel."

read _

THIS=$( dirname $0 )
nice R -f $THIS/install-candle.R
