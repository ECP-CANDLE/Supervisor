#!/bin/bash
set -eu

# INSTALL CANDLE R

# Installs all R packages needed for Supervisor workflows

# pass CONFIRM=0 via command line for by passing options,
#      default is CONFIRM=1
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

if ! command which R > /dev/null
then
  echo "No R found!"
  exit 1
fi

echo "variables:"
set +u  # These variables may be unset
for var in CC CXX FC
do
  printf "using %-8s = %s\n" $var ${!var}
done
echo
set -u

echo "tools:"
for tool in R cc CC gcc g++ ftn gfortran
do
  if command which $tool > /dev/null 2>&1
  then
    printf "using %-10s %s\n" "${tool}:"  $( which $tool )
  fi
done
echo

if [ $CONFIRM = 1 ]
then
  sleep 1
  echo "Press enter to confirm, or Ctrl-C to cancel."
  read _
fi

THIS=$( dirname $0 )
nice R -f $THIS/install-candle.R |& tee install-candle.log
