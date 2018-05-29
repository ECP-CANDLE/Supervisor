#!/bin/sh
set -eu

# INSTALL CANDLE R

# Installs all R packages needed for Supervisor workflows

# pass CONFIRM=0 via command line for by passing options, default is CONFIRM=1
: ${CONFIRM:=1}
while getopts ":y" OPTION
do
  case $OPTION in
    y) CONFIRM=0
       ;;
    *) # The shell error message was disabled above
       echo "install-candle.sh: unknown option: $*"
       exit 1
       ;;
  esac
done

echo "This will install multiple R packages for CANDLE."
echo
echo "using R:        $( which R )"
echo "using gcc:      $( which gcc )"
echo "using gfortran: $( which gfortran )"
echo

if [ $CONFIRM = 1 ]
then
  sleep 1
  echo "Press enter to confirm, or Ctrl-C to cancel."
  read _
fi

THIS=$( dirname $0 )
nice R -f $THIS/install-candle.R
