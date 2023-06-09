#!/bin/sh
set -eu

# TOUCH ALL SH
# Touch all files in given experiment directories
# to prevent auto-deletion
# Finds dot files too

THIS=$( readlink --canonicalize $( dirname $0 ) )

{
  for DIR in $*
  do
    nice find $DIR
  done
} | $THIS/count-lines.awk | xargs -n 16 touch
